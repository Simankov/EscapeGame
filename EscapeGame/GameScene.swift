//
//  GameScene.swift
//  EscapeGame
//
//  Created by admin on 31.01.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import SpriteKit



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
    var spawnChainOneTime : Bool = false
     var lastBuild =  Build()
    
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
        chain = Chain(countChains: _countOfChains, scale : _scaleOfChain)
        backgroundLayer.addChild(chain)
        
        chain.addAdditionalJoints();
        chain.position = CGPointMake(150, 3000)
        
        // setup hero
        hero.position = CGPoint(x: hero.frame.width/2, y: 800)
        hero.chain = chain
        chain.firstChain.position =
            convertPoint(
                convertPoint(hero.position, fromNode: backgroundLayer),
                toNode : chain
        )
        
        hero.addJointWithChain()
        hero.addBasket()
        
        physicsWorld.addJoint(SKPhysicsJointFixed.jointWithBodyA(hero.physicsBody, bodyB: hero.basket.physicsBody, anchor: CGPointZero))
        
        // gestures
        swipeRecognizer.addTarget(self, action: "swipe")
        view.addGestureRecognizer(swipeRecognizer)
        view.userInteractionEnabled = true
        
        view.showsPhysics = false
        physicsWorld.gravity = CGVectorMake(0, -13.8)
        
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
        
        if convertPoint(hero.position, fromNode: backgroundLayer).x + hero.size.width/2 < 0 || convertPoint(hero.position, fromNode: backgroundLayer).x - hero.size.width/2 > CGRectGetMaxX(playableArea) || convertPoint(hero.position, fromNode: backgroundLayer).y < CGRectGetMinY(playableArea)
        {
            restart()
        }
        
        if convertPoint(convertPoint(chain.hookNode.position, fromNode: chain), toNode: backgroundLayer).y < convertPoint(playableArea.origin, toNode: backgroundLayer).y
        {
//            jumpToLoose()
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
        
        if hero.state == .Stand
        {
//            checkHeroPositionOnBlock()
        }
        
        let endScreen = convertPoint(CGPointMake(self.size.width,0), toNode: backgroundLayer)
        
        if lenghtBetweenBuildes == 0 {
            var width = randomFloat(_minWidthBuild, _maxWidthBuild)
            var height = randomFloat(_minHeightBuild, _maxHeightBuild)
            spawnBuild(lastBuildPosition + lenghtBetweenBuildes + width/2, size: CGSizeMake(width, height))
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
            
            while (alpha * 57.3 > 36){
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
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (PhysicsCategory.Build | PhysicsCategory.Hero) && spawnChainOneTime && status == .Playable
        {
            hero.state = .Stand
            hero.animate(.EndJump)
            increaseScore()
            
            spawnChainOneTime = false
            restartChain()
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
    
    func jumpToLoose()
    {
        intersectHeroAndBuild()
        hero.jump(CGPoint(x: chain.hookNode.position.x + hero.size.width/2 , y: chain.hookNode.position.y))
        hero.state = .Loose
        hero.physicsBody!.collisionBitMask = PhysicsCategory.None
        hero.physicsBody!.contactTestBitMask = PhysicsCategory.None
    }
    
    func increaseScore()
    {
        
    }
    
    func restart(){
        removeAllChildren()
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene.scaleMode = .AspectFill
        gameScene.view?.showsFPS = true
        self.view?.presentScene(gameScene)
    
    }
    
    func restartChain()
    {
       
        if status == .Playable
        {
            var chain2 = Chain()
            chain.runAction(SKAction.sequence([SKAction.runBlock({
                
                chain2 = Chain(countChains: 34, scale : 6)
               self.chain = chain2
                self.hero.chain = chain2
                self.backgroundLayer.addChild(chain2)
                chain2.addAdditionalJoints();
                chain2.position = CGPointMake(self.hero.position.x,self.hero.position.y + 2000)
                
               chain2.firstChain.position = self.convertPoint(
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
    
    func increaseCounter()
    {
        counter += CGFloat(timer.timeInterval);
        var c = counter * counter
        if c > _maxTimeOfPress
        {
            c = _maxTimeOfPress
        }
        c += 0.7
        println(c)
    }
}
