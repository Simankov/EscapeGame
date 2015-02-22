//
//  Chain.swift
//  EscapeGame
//
//  Created by admin on 07.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import SpriteKit

class Chain : SKNode{
    
    enum State: String{
        case UnderControll = "controlled"
        case InFly = "flyihg"
        case Stopped = "stopped"
    }
    
    var currentState: State = .Stopped
    let imageName : String = "rope3"
    var chains : [SKSpriteNode] = [SKSpriteNode]()
    var hookNode : SKSpriteNode = SKSpriteNode(imageNamed: "shape")
    var firstChain : SKSpriteNode = SKSpriteNode();
    var lastChain  : SKSpriteNode = SKSpriteNode()
    var joints : [SKPhysicsJoint] = [SKPhysicsJoint]()
    var build = Build()

    convenience init (countChains : Int, scale : CGFloat)
    {
        self.init()
        
        var startPosition: CGFloat = 0
        
        
        firstChain = SKSpriteNode(imageNamed: imageName)
        firstChain.position = CGPointZero
        firstChain.name = "firstChain"
        firstChain.setScale(scale)
        firstChain.zPosition = 0.5
        firstChain.physicsBody = SKPhysicsBody(circleOfRadius: firstChain.frame.size.height/2)
        firstChain.physicsBody!.dynamic = false
        firstChain.physicsBody!.categoryBitMask = PhysicsCategory.Chain
        firstChain.physicsBody!.collisionBitMask =  PhysicsCategory.Build
        self.addChild(firstChain)
        chains.append(firstChain)
        
        lastChain = firstChain
        for i in 1...countChains {
            
            let chainNode = SKSpriteNode(imageNamed: imageName)
            
            chainNode.position = CGPoint(x: lastChain.position.x, y: CGRectGetMinY(lastChain.frame) - lastChain.frame.height/2)
            chainNode.setScale(scale)
            
            chainNode.zPosition = 0.5
            
            chainNode.physicsBody = SKPhysicsBody(circleOfRadius: chainNode.frame.size.height/2)
            chainNode.physicsBody!.restitution = 0.1
            chainNode.physicsBody!.categoryBitMask = PhysicsCategory.Chain
            chainNode.physicsBody!.collisionBitMask =   PhysicsCategory.Build | PhysicsCategory.Antenna
            
            self.addChild(chainNode)
            
            //            pinJoint.upperAngleLimit = 5 * CGFloat( M_PI / 6 )
            //            pinJoint.lowerAngleLimit = 5 * CGFloat( M_PI / -6)
            //            pinJoint.shouldEnableLimits = true
          
            chains.append(chainNode)
            lastChain = chainNode
        }
        
        createHook(CGPoint(x:lastChain.position.x, y: CGRectGetMinY(lastChain.frame)))
    }
    
    override init()
    {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createHook(position: CGPoint){
        
        hookNode.name = "hook"
        
        hookNode.position = CGPoint(x: position.x, y: position.y )
        
        hookNode.zPosition = 134
        hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.frame.height/2)
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.Hook
        hookNode.physicsBody!.collisionBitMask =  PhysicsCategory.Cannon | PhysicsCategory.Build | PhysicsCategory.Fire | PhysicsCategory.Antenna
        hookNode.physicsBody!.density = 40;
        hookNode.physicsBody!.friction = 8999
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
        hookNode.setScale(1.4)
        
        self.addChild(hookNode)
        chains.append(hookNode)
    }
    
    func addAdditionalJoints(){
    
        for i in 0 ... chains.count-1
        {
            if chains[i].name != "hook" && chains[i].name != "firstChain"
            {
                // this is so ugly because of changing coordinates
                
                let limJointWithHook = SKPhysicsJointLimit.jointWithBodyA(hookNode.physicsBody!, bodyB: chains[i].physicsBody! ,
                  anchorA: getInScene(hookNode.position),
                  anchorB: getInScene(chains[i].position)
                )
                
                limJointWithHook.maxLength = chains[i].position.y - hookNode.position.y;
                
                let pinJointWithOther = SKPhysicsJointPin.jointWithBodyA(chains[i].physicsBody!, bodyB: chains[i-1].physicsBody!,
                    anchor: getInScene(CGPoint(x: chains[i].position.x, y: chains[i-1].position.y - chains[i-1].size.height/2 )
                    ))
                
                let aaa = getInScene(CGPoint(x: chains[i].position.x, y: chains[i-1].position.y + chains[i-1].size.height/2))

                
                let limJointWithFirst = SKPhysicsJointLimit.jointWithBodyA(firstChain.physicsBody!, bodyB: chains[i].physicsBody!,
                    anchorA: getInScene(firstChain.position),
                    anchorB: getInScene(chains[i].position))
                
                limJointWithFirst.maxLength = firstChain.position.y - chains[i].position.y;
                
                scene?.physicsWorld.addJoint(limJointWithHook)
                scene?.physicsWorld.addJoint(pinJointWithOther)
                scene?.physicsWorld.addJoint(limJointWithFirst)
            }
            
            
            if chains[i].name == "hook"
            {
                let limJoint = SKPhysicsJointLimit.jointWithBodyA(firstChain.physicsBody, bodyB: hookNode.physicsBody,
                    anchorA: getInScene(CGPoint(x: firstChain.position.x, y: CGRectGetMaxY(firstChain.frame))),
                    anchorB: getInScene(CGPoint(x:position.x, y: CGRectGetMinY(lastChain.frame))))
                
                limJoint.maxLength = CGRectGetMaxY(firstChain.frame) - CGRectGetMinY(lastChain.frame)
                
                let fixJoint = SKPhysicsJointPin.jointWithBodyA(lastChain.physicsBody, bodyB: hookNode.physicsBody,
                    anchor: getInScene(CGPoint(x: position.x, y: lastChain.position.y - lastChain.size.height/2 )))
                
                scene?.physicsWorld.addJoint(fixJoint)
                scene?.physicsWorld.addJoint(limJoint)
            }
        }
    }
    
    func getInScene(point: CGPoint) -> CGPoint
    {
        let one =  convertPoint(point, fromNode: self)
        return one
    }

    
    func updateState()
    {
   
        if hookNode.physicsBody!.dynamic == false
        {
            currentState = .UnderControll
            
        }else{
            
            let gameScene = scene as GameScene
            let inScene = gameScene.convertPoint(hookNode.position, fromNode: gameScene.chain)
            let inHero = gameScene.convertPoint(inScene, toNode: gameScene.backgroundLayer)
           
            if self.hookNode.physicsBody!.velocity.length() < 3 && abs(hookNode.physicsBody!.angularVelocity) < 0.1
            {
                currentState = .Stopped
                
                if self.build.number != gameScene.hero.build.number && gameScene.status  != .Wait
                {
                   let targetPosition =
                        gameScene.convertPoint(gameScene.convertPoint(hookNode.position, fromNode: gameScene.chain), toNode: gameScene.backgroundLayer)
                    
                    gameScene.hero.jump(targetPosition)
                    gameScene.runOneTime = false
                }
                
            }else{
                
                currentState = .InFly
            }
        }
        
    }

} // class end