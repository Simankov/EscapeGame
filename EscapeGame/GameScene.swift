//
//  GameScene.swift
//  EscapeGame
//
//  Created by admin on 31.01.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import SpriteKit

struct PhysicsCategory
{
    static var None: UInt32 = 0
    static var Edge: UInt32 = 1
    static var Chain: UInt32 = 2
    static var Hook : UInt32 = 4
    static var Cannon : UInt32 = 8
    static var Build : UInt32 = 16
    static var Hero : UInt32 = 32
    static var Antenna : UInt32 = 64
    static var Fire : UInt32 = 128
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum Status
    {
        case Wait
        case Playable
    }
    
    var playableArea: CGRect = CGRect()
    var touchedNode : SKNode? = SKNode()
    var timer: NSTimer = NSTimer()
    let backgroundLayer = SKNode()
    var chain = Chain()
    var startPosition : CGPoint = CGPointZero;
    var endPosition: CGPoint = CGPointZero
  
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
    
    override func didMoveToView(view: SKView) {
        prepareScene()
        
        // setup background
        backgroundColor = UIColor.whiteColor()
        backgroundLayer.name = "backgroundLayer"
        backgroundLayer.zPosition = -1
        backgroundLayer.physicsBody = SKPhysicsBody(circleOfRadius: 3)
        backgroundLayer.physicsBody?.dynamic = false
        
        backgroundLayer.addChild(hero)
        
        addChild(backgroundLayer)
        
        // setup chain
        chain = Chain(countChains: 34, scale : 6) as Chain
        backgroundLayer.addChild(chain)
        
        chain.addAdditionalJoints();
        chain.position = CGPointMake(150, 3000)
        chain.firstChain.position =
            convertPoint(
                convertPoint(hero.position, fromNode: backgroundLayer),
                toNode : chain
        )
        
        // setup hero
        hero.position = CGPoint(x: hero.frame.width/2, y: 900)
        hero.chain = chain
        hero.addJointWithChain()
        
        // gestures
        swipeRecognizer.addTarget(self, action: "swipe")
        view.addGestureRecognizer(swipeRecognizer)
        view.userInteractionEnabled = true
        
        view.showsPhysics = true
        physicsWorld.gravity = CGVectorMake(0, -9.8)
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
       startPosition = (touches.anyObject() as UITouch).locationInNode(self)
        
       touchedNode  = nodeAtPoint(startPosition) as SKNode
       status = .Playable
   
        if touchedNode?.name == "backgroundLayer"
        {
             timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "increaseCounter", userInfo: nil, repeats: true)
             currentTouchPosition = (touches.anyObject() as UITouch).locationInNode(backgroundLayer)
        }
        
        if touchedNode?.name == "button"
        {
            self.restart()
        }
        
        if touchedNode?.name == "hook"
        {
            flagMovedObjects = true
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
    
    func spawnBuild(point : CGFloat)
    {
        let build = Build(posY: CGRectGetMinY(playableArea), minHeight : 400, maxHeight: 600, minWidth: 150, maxWidth: 700)

        build.position.x = point + build.size.width/2
        build.zPosition = 1
        build.name = "build"
        lastBuildPosition = build.position.x
        backgroundLayer.addChild(build)
        build.fixJointAntenn()
      
        let fixJoint = SKPhysicsJointFixed.jointWithBodyA(backgroundLayer.physicsBody, bodyB: build.physicsBody, anchor: CGPointZero)
        physicsWorld.addJoint(fixJoint)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if !flagMovedObjects {
            let count = touches.count
            let position = (touches.anyObject() as UITouch).locationInNode(backgroundLayer)
            
            let timeOfTouch = counter
            timer.invalidate()
            
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
        if convertPoint(chain.hookNode.position, fromNode: chain).y < CGRectGetMinY(playableArea)
        {
            intersectHeroAndBuild()
            hero.jump(convertPoint(convertPoint(chain.hookNode.position, fromNode: chain), toNode: backgroundLayer))
           
        }
        
        if convertPoint(hero.position, fromNode: backgroundLayer).x + hero.size.width/2 < 0 || convertPoint(hero.position, fromNode: backgroundLayer).x - hero.size.width/2 > CGRectGetMaxX(playableArea)
        {
            restart()
        }
        
        if convertPoint(hero.position, fromNode: backgroundLayer).x > 400 && hero.physicsBody!.velocity == CGVectorMake(0, 0) && !runOneTime && !heroFall
        {
            let speed : Double = 1000
            let delta : Double = Double(convertPoint(hero.position, fromNode: backgroundLayer).x - 400)
            let time = delta / speed as Double
            backgroundLayer.removeActionForKey("move")
            backgroundLayer.runAction(SKAction.moveByX(-CGFloat(delta), y: backgroundLayer.position.y, duration: time), withKey: "move")
            runOneTime = true
         
        }
        
        if hero.state == .Stand
        {
//            checkHeroPositionOnBlock()
        }
        
        let endScreen = convertPoint(CGPointMake(self.size.width,0), toNode: backgroundLayer)
       
        if lastBuildPosition + lenghtBetweenBuildes < endScreen.x    {
            spawnBuild(lastBuildPosition + lenghtBetweenBuildes)
            lenghtBetweenBuildes = randomFloat(800, 1200)
        } else if lenghtBetweenBuildes == 0 {
            lenghtBetweenBuildes = randomFloat(800, 1200)
        }
        
        chain.updateState()
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
            intersectHeroAndBuild()
            hero.jump(CGPoint(x: chain.hookNode.position.x + hero.size.width/2 , y: chain.build.end().y))
        }
        
        if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == PhysicsCategory.Hero | PhysicsCategory.Edge
        {
            self.restart()
        }
    }
    
    func restart(){
        removeAllChildren()
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene.scaleMode = .AspectFill
        gameScene.view?.showsFPS = true
        self.view?.presentScene(gameScene)
    
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
            
            println("sefegergrt")
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
    
    func increaseCounter()
    {
        counter += CGFloat(timer.timeInterval);
     
    }
}
