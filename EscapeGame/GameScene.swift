//
//  GameScene.swift
//  EscapeGame
//
//  Created by admin on 31.01.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import SpriteKit
import AVFoundation
let defaults = NSUserDefaults.standardUserDefaults()


class ReleaseScene : SKScene
{
    
}

protocol viewEndGameDelegate: class
{
    func viewDidEndGame()
}
class TestScene: SKScene {
    weak var delegate2: viewEndGameDelegate?
    override func update(currentTime: NSTimeInterval) {
        delegate2?.viewDidEndGame()
    }
        
    
}

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    enum Status
    {
        case Wait
        case Playable
    }
    enum Sound
    {
        case Loose
        case Jump
    }
    weak var viewDelegate : viewEndGameDelegate?
    
    var score =  SKLabelNode()
    var playableArea: CGRect = CGRect()
    var touchedNode : SKNode? = SKNode()
    weak var timer: NSTimer?
    var backgroundLayer = SKNode()
    var chain = Chain()
    var startPosition : CGPoint = CGPointZero;
    var endPosition: CGPoint = CGPointZero
    var scorePoint: NSInteger = 0
    var player : AVAudioPlayer?
    var sounded: Bool = false
    var isApplied = false
    
    var lastBuildPosition: CGFloat = 0
    var currentTouchPosition: CGPoint = CGPointZero
    var lenghtBetweenBuildes :CGFloat = 0
    var dt : CGFloat = 0;
    var counter : CGFloat = 0;
    var lastUpdateTime : CGFloat = 0;
    let hero = Hero()
    var status: Status = .Wait
    let swipeRecognizer  = UISwipeGestureRecognizer()
    var flagMovedObjects: Bool = false;
    var targetPosition : CGPoint = CGPointZero
    var runOneTime : Bool = false
    var heroFall: Bool = false
    var spawnChainOneTime : Bool = false
     var lastBuild =  Build()
    var isEffectsEnabled : Bool = true
var isRestarted : Bool = false
    var audioPlayer = AudioPlayer()
    
    
    override func didMoveToView(view: SKView) {
        prepareScene()
    

        // setup background
        timer = NSTimer()
        var background = SKSpriteNode()
        background.size = CGSize(width: 2048, height: 1536)
        background.position = CGPointMake( 1024,  768)
        background.zPosition = -1
        backgroundColor = UIColor.whiteColor()
        
//        backgroundLayer.addChild(background)
        backgroundLayer.name = "backgroundLayer"
        backgroundLayer.zPosition = -1
        backgroundLayer.physicsBody = SKPhysicsBody(circleOfRadius: 3)
        backgroundLayer.physicsBody?.dynamic = false
        
        backgroundLayer.addChild(hero)
        
        addChild(backgroundLayer)
        
        var width = randomFloat(_minWidthBuild, _maxWidthBuild)
        var height = randomFloat(_minHeightBuild, _maxHeightBuild)
        spawnBuild( width/2, size: CGSizeMake(width, height))
        
        
        
        
        // gestures
        swipeRecognizer.addTarget(self, action: "swipe")
        view.addGestureRecognizer(swipeRecognizer)
        view.userInteractionEnabled = true
        println(hero.size)
        view.showsPhysics = false
        physicsWorld.gravity = CGVectorMake(0, -14.8)
        score = SKLabelNode(fontNamed: "Hiragino Kaku Gothic ProN W3")
        score.position = CGPointMake(CGRectGetMidX(playableArea), CGRectGetMaxY(playableArea) - 200)
       
        score.fontSize = 170
        score.text = " "
        self.delegate = nil
        score.fontColor = UIColor.blackColor()
        addChild(score)
        physicsWorld.addJoint(SKPhysicsJointFixed.jointWithBodyA(hero.physicsBody, bodyB: hero.basket.physicsBody, anchor: CGPointZero))
    }
    
    func prepareScene()
    {
        let maxAspectRatio : CGFloat = 16/9;
        let maximumHeight = size.width / maxAspectRatio
        let margin = (size.height - maximumHeight) / 2
        self.physicsWorld.contactDelegate = self
        playableArea = CGRect(x: 0, y: margin, width: size.width, height: maximumHeight)
        
        let playableAreaPath = CGPathCreateMutable()
        CGPathMoveToPoint(playableAreaPath, nil, playableArea.size.width, CGRectGetMinY(playableArea))
        CGPathAddLineToPoint(playableAreaPath, nil, 0, CGRectGetMinY(playableArea))
        
        self.physicsBody = SKPhysicsBody(edgeChainFromPath: playableAreaPath)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        self.physicsBody!.collisionBitMask = PhysicsCategory.Chain | PhysicsCategory.Edge | PhysicsCategory.Hook | PhysicsCategory.Hero
        
    }
    
    
 override  func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    
    
       startPosition = (touches.anyObject() as UITouch).locationInNode(self)
        
       touchedNode  = nodeAtPoint(startPosition) as SKNode
       status = .Playable
   
    
             timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "increaseCounter", userInfo: nil, repeats: true)
             currentTouchPosition = (touches.anyObject() as UITouch).locationInNode(backgroundLayer)
        
        if touchedNode?.name == "button"
        {
            self.restart()
        }

    
    }
    

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if !flagMovedObjects {
            currentTouchPosition = (touches.anyObject() as UITouch).locationInNode(backgroundLayer)
        }else{
            
            if touchedNode?.name != "hook"
            {
                touchedNode?.position = convertPoint((touches.anyObject() as UITouch).locationInNode(self), toNode: backgroundLayer)
            }else{
                touchedNode?.position = convertPoint((touches.anyObject() as UITouch).locationInNode(self), toNode: chain)
            }
        }
    }
    
    func spawnBuild(point : CGFloat, size : CGSize)
{
        
        let build = Build(posY: CGRectGetMinY(playableArea), size: size)
        
        build.position.x = point
        build.zPosition = 1
        build.name = "build"
        
        
        
        lastBuild = build
        lastBuildPosition = build.position.x
        backgroundLayer.addChild(build)
    
        if _countOfBuilds == 1
        {
            chain = Chain(countChains: _countOfChains, scale : _scaleOfChain)
            hero.position = CGPointMake(hero.size.width/2 + 100, CGRectGetMinY(playableArea) + build.size.height + hero.size.height/2 + 4)
            
            
            
            
            backgroundLayer.addChild(chain)
            
            chain.addAdditionalJoints();
            
            chain.position = CGPointMake(hero.position.x,  3000)
            // setup hero
            chain.hookNode.position = convertPoint( convertPoint(hero.position, fromNode: backgroundLayer) , toNode: chain)
            hero.chain = chain
            chain.firstChain.position =
                convertPoint(
                    convertPoint(hero.position, fromNode: backgroundLayer),
                    toNode : chain
            )
            
            hero.addJointWithChain()
            hero.addBasket()

        }
    
    
        let fixJoint = SKPhysicsJointFixed.jointWithBodyA(backgroundLayer.physicsBody, bodyB: build.physicsBody, anchor: CGPointZero)
        physicsWorld.addJoint(fixJoint)
        


    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if !flagMovedObjects {
            let count = touches.count
            let position = (touches.anyObject() as UITouch).locationInNode(backgroundLayer)
            
            let timeOfTouch = counter
            timer!.invalidate()
            
            counter = 0;
            hero.powerMultiple = timeOfTouch
            hero.shot(position)
        }
        
        flagMovedObjects = false
    }
    
   
    func didEndContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == PhysicsCategory.Edge | PhysicsCategory.Build
        {
            if contact.bodyA.categoryBitMask == PhysicsCategory.Build
            {
                contact.bodyA.node?.removeFromParent()
            }else{
                contact.bodyB.node?.removeFromParent()
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0
        {
            dt = CGFloat(currentTime) - lastUpdateTime
        }else{
            dt = 0
        }
        
        if hero.position.x > hero.chain.build.position.x + hero.chain.build.size.width/2 - hero.size.width/2 + 10 && hero.state == .Fly
        {
            hero.physicsBody?.velocity = CGVectorMake(0, -500)
        }
        println(hero.state.rawValue)
        lastUpdateTime = CGFloat(currentTime)
        hero.updateState()
        let positionHook = convertPoint(chain.hookNode.position , fromNode: chain)
//        let offset = convertPoint(positionHook, toNode: backgroundLayer).x - convertPoint( CGPoint(x:CGRectGetMaxX(frame)-300, y:0), toNode: backgroundLayer).x
//            
//        if offset > 0
//        {
//            backgroundLayer.position.x -= offset
//        }
        
        // fix bug with hook out of screen
        if convertPoint(chain.hookNode.position, fromNode: chain).y < CGRectGetMinY(playableArea) && status == .Playable
        {
            
            jumpToLoose()
           
        }
        
        if convertPoint(hero.position, fromNode: backgroundLayer).x + hero.size.width/2 < 0 || convertPoint(hero.position, fromNode: backgroundLayer).x - hero.size.width/2 > CGRectGetMaxX(playableArea) || convertPoint(hero.position, fromNode: backgroundLayer).y  < CGRectGetMinY(playableArea)
        {
            restart()
        }
       
        
        
       
        
        if convertPoint(hero.position, fromNode: backgroundLayer).x > _DistanceFromEdge && hero.physicsBody!.velocity == CGVectorMake(0, 0) && !runOneTime && !heroFall
        {
            let speed : Double = Double(_backgroundMoveSpeed)
            let delta : Double = Double(convertPoint(hero.position, fromNode: backgroundLayer).x - _DistanceFromEdge)
            let time = delta / speed as Double
            backgroundLayer.removeActionForKey("move")
            backgroundLayer.runAction(SKAction.moveByX(-CGFloat(delta), y: backgroundLayer.position.y, duration: time), withKey: "move")
            runOneTime = true
         
        }
        
//        
//        if hero.state == .Loose && hero.position.y - CGRectGetMinY(playableArea) < 400 && !sounded
//        {
//        
//            sound(.Loose)
//            sounded = true
//            
//        }
        
        let endScreen = convertPoint(CGPointMake(self.size.width,0), toNode: backgroundLayer)
        
        if lenghtBetweenBuildes == 0 {
            
            lenghtBetweenBuildes = randomFloat(_minLenghtBetweenBuilds, _maxLenghtBetweenBuilds)
            
        }
        else
          if lastBuildPosition + lenghtBetweenBuildes < endScreen.x    {
            var width = randomFloat(_minWidthBuild, _maxWidthBuild)
            var height = randomFloat(_minHeightBuild, _maxHeightBuild)
            lenghtBetweenBuildes = randomFloat(_minLenghtBetweenBuilds, _maxLenghtBetweenBuilds)
            var rightTop = CGPointMake(lastBuild.position.x + lastBuild.size.width/2, lastBuild.position.y + lastBuild.size.height/2)
            var leftTop = CGPointMake(lastBuild.position.x + lenghtBetweenBuildes - width/2, CGRectGetMinY(playableArea) + height)
            var alpha = atan((leftTop.y - rightTop.y ) / (leftTop.x - rightTop.x))
//            println(alpha * 57.3)
//            println(lenghtBetweenBuildes)
//            println(rightTop)
//             println(leftTop)
            
            while (alpha * 57.3 > 30 ) {
             width = randomFloat(_minWidthBuild, _maxWidthBuild)
             height = randomFloat(_minHeightBuild, _maxHeightBuild)
            lenghtBetweenBuildes = randomFloat(_minLenghtBetweenBuilds, _maxLenghtBetweenBuilds)
                var rightTop = CGPointMake(lastBuild.position.x + lastBuild.size.width/2, lastBuild.position.y + lastBuild.size.height/2)
                var leftTop = CGPointMake(lastBuild.position.x + lenghtBetweenBuildes - width/2, CGRectGetMinY(playableArea) + height)
                alpha = atan((leftTop.y - rightTop.y ) / (leftTop.x - rightTop.x))
            }
            spawnBuild(lastBuild.position.x + lenghtBetweenBuildes, size: CGSizeMake(width, height))
            
            lenghtBetweenBuildes = randomFloat(_minLenghtBetweenBuilds, _maxLenghtBetweenBuilds)
        }
        
        if chain.parent != nil{
        chain.updateState()
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
       
        
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (PhysicsCategory.Build | PhysicsCategory.Hook)
        {
            chain.hookNode.physicsBody!.velocity = CGVectorMake(0, 0)
            
            if contact.bodyB.categoryBitMask == PhysicsCategory.Build
            {
                chain.build = (contact.bodyB.node as Build)
            }
            else
            {
                chain.build = (contact.bodyA.node as Build)
            }
        }
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (PhysicsCategory.Build | PhysicsCategory.Hero)
        {
            hero.state = .Stand
            hero.animate(.EndJump)
            
            
            if spawnChainOneTime
            {
            restartChain()
            increaseScore()
            spawnChainOneTime = false
            }
            if contact.bodyA.categoryBitMask == PhysicsCategory.Hero
            {
                contact.bodyA.node!.physicsBody?.velocity = CGVectorMake(0, 0)
                
                hero.build = (contact.bodyB.node as Build)
            } else {
                contact.bodyB.node!.physicsBody?.velocity = CGVectorMake(0, 0)
                
                hero.build = (contact.bodyA.node as Build)
            }
        }
        
        if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == PhysicsCategory.Edge | PhysicsCategory.Hook
        {
            jumpToLoose()
        }
    }
    
        
    func sound(type : Sound)
    {
        if isEffectsEnabled
        {
        
        if type == .Jump
        {
        audioPlayer.play(.Jump)
        }
        else if type == .Loose
        {
        audioPlayer.play(.Fail)
        }
            
        }
    }
        
    
    
    func jumpToLoose()
    {
        if scene != nil    // temporaryFix
        {
        let hookPosition = convertPoint(convertPoint(chain.hookNode.position, fromNode: chain), toNode: backgroundLayer)
        hero.state = .Loose
        hero.jump(CGPoint(x: hookPosition.x , y: hookPosition.y))
            if !sounded
            {
        audioPlayer.play(.Fail)
                sounded = true
            }
        hero.physicsBody!.collisionBitMask = PhysicsCategory.None
        hero.physicsBody!.contactTestBitMask = PhysicsCategory.Edge
        for chain in hero.chain.chains
        {
            chain.physicsBody!.collisionBitMask = PhysicsCategory.None
        }
        }
    }
    
    func increaseScore()
    {
        scorePoint++
        score.text = String(scorePoint)
        
    }
    
  
    func restart(){
        
        if !isRestarted
        {
            
            defaults.setObject(scorePoint, forKey: "score")
            
            if defaults.integerForKey("highScore") != 0
            {
                if defaults.integerForKey("highScore") < scorePoint
                {
                    defaults.setObject(scorePoint, forKey: "highScore")
                }
            }
            else
            {
                defaults.setObject(scorePoint, forKey: "highScore")
            }
            
            defaults.synchronize()
           
            
            
            removeAllChildren()
            let gameScene = GameScene(fileNamed: "GameScene")
            _countOfBuilds = 0
            scorePoint = 0
            gameScene.scaleMode = .AspectFill
            gameScene.view?.showsFPS = true
//            self.view?.presentScene(gameScene)
            for sub in view!.subviews
            {
                sub.removeFromSuperview()
            }
            viewDelegate?.viewDidEndGame()
            
//    self.view?.window?.rootViewController?.presentViewController( self.view?.window?.rootViewController?.storyboard!.instantiateViewControllerWithIdentifier("EndGameViewController") as EndGameViewController, animated: true, completion: nil)
            
            
            isRestarted = true
        }
        }
    


    
    
    func restartChain()
    {
       
        if status == .Playable
        {
            var chain2 = Chain()
            chain.runAction(SKAction.sequence([SKAction.runBlock({
                
                chain2 = Chain(countChains: _countOfChains, scale : _scaleOfChain)
               self.chain = chain2
                self.hero.chain = chain2
                self.backgroundLayer.addChild(chain2)
                chain2.addAdditionalJoints();
                let space = self.hero.size.width
                let spacePerChain = space / CGFloat(chain2.chains.count)
                for (index,chain) in enumerate(chain2.chains)
                {
                    
                    (chain as SKSpriteNode).position = self.convertPoint(self.convertPoint(CGPoint(x: self.hero.position.x - self.hero.size.width/2 + spacePerChain * CGFloat(index) , y: self.hero.position.y), fromNode: self.backgroundLayer), toNode: self.chain)
                }
               chain2.firstChain.position = self.convertPoint(
                        self.convertPoint(self.hero.position, fromNode: self.backgroundLayer),
                        toNode : chain2)
                chain2.hookNode.position = self.convertPoint(
                    self.convertPoint(self.hero.position, fromNode: self.backgroundLayer),
                    toNode : chain2)
                self.hero.addJointWithChain()
                
                }
                )
            ,SKAction.removeFromParent()]))
           
            
        }
    }
    func checkHeroPositionOnBlock()
    {
         if !heroFall && status == .Playable
         {
            
              if hero.position.x < CGRectGetMinX(hero.build.frame) {
            
            hero.physicsBody!.angularVelocity = 2.5;
            heroFall = true
            
               }
            else
               {
             if hero.position.x > CGRectGetMaxX(hero.build.frame)
               {
                let max = CGRectGetMaxX(hero.build.frame)

                let safsf = hero.position.x;
                    hero.physicsBody!.angularVelocity = -2.5;
                    heroFall = true
                }
                }
        }
        

        
    }
    
    
    func swipe(){
        if !flagMovedObjects
        {
            let count = swipeRecognizer.numberOfTouches()
            currentTouchPosition =  convertPoint(swipeRecognizer.locationOfTouch(count-1, inView: view), toNode: backgroundLayer)
        }
    }
    
    func intersectHeroAndBuild(){
        let inScene = convertPoint(self.chain.hookNode.position, fromNode: chain)
        let inBackground = convertPoint(inScene, toNode: backgroundLayer)
        let origin = CGPoint(x: inBackground.x - self.hero.size.width/2, y : inBackground.y - self.hero.size.height/2)
        var count = 0;
        
        enumerateChildNodesWithName("//build"){
            node, _ in
            
            
            let distance = abs(inBackground.x - self.hero.build.position.x)
            if distance <= self.hero.size.width/2 + self.hero.build.size.width/2
            {
                if distance <= self.hero.build.size.width/2
                {
                    self.hero.intersect = .In
                }
                    count++
                    if inBackground.x - self.hero.build.position.x <= self.hero.size.width/2 + self.hero.build.size.width/2 && inBackground.x >= self.hero.position.x
                    {
                        self.hero.intersect = .Left
                    }
                    else
                    {
                        self.hero.intersect = .Right
                    }
            }
        }
        
        if count == 0
        {
           hero.intersect = .None
          
        }
    }
    
   deinit {
   
    println("dealloc")
    }
    
    func increaseCounter()
    {
        if timer != nil
        {
        counter += CGFloat(timer!.timeInterval);
        }
        
       
    }
}
