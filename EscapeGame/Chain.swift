//
//  Chain.swift
//  EscapeGame
//
//  Created by admin on 07.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Chain : SKNode, AVAudioPlayerDelegate{
    
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
        firstChain.physicsBody!.dynamic = true
        firstChain.physicsBody!.density = 122;
        firstChain.physicsBody!.categoryBitMask = PhysicsCategory.Chain
        firstChain.physicsBody!.collisionBitMask =  PhysicsCategory.Build
        self.addChild(firstChain)
        chains.append(firstChain)
        
        lastChain = firstChain
        for i in 1...countChains {
            
            let chainNode = SKSpriteNode(imageNamed: imageName)
            
            chainNode.position = CGPoint(x: lastChain.position.x, y: CGRectGetMinY(lastChain.frame) - lastChain.frame.height/2)
            chainNode.setScale(scale)
            
            chainNode.zPosition = 1001
            chainNode.physicsBody = SKPhysicsBody(circleOfRadius: chainNode.frame.size.height/2)
            chainNode.physicsBody!.restitution = 0.1
             chainNode.physicsBody!.density = 122;
            chainNode.physicsBody!.friction = 0
            chainNode.physicsBody!.usesPreciseCollisionDetection = false
            chainNode.physicsBody!.categoryBitMask = PhysicsCategory.Chain
            chainNode.physicsBody!.collisionBitMask =   PhysicsCategory.Build | PhysicsCategory.Antenna | PhysicsCategory.Busket
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
        
        hookNode.zPosition = 1334
        hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.frame.height/2)
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.Hook
        hookNode.physicsBody!.collisionBitMask =  PhysicsCategory.Cannon | PhysicsCategory.Build | PhysicsCategory.Fire | PhysicsCategory.Busket
        hookNode.physicsBody!.density = _hookNodeDensity
        hookNode.physicsBody!.friction = 1
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
        hookNode.setScale(_hookNodeScale)
        
        self.addChild(hookNode)
        chains.append(hookNode)
    }
    
    func changeCollisionMaskForChains()
    {
 
        for chain in chains
        {
            chain.physicsBody!.collisionBitMask = PhysicsCategory.Build 
        }

       
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

                
                let limJointWithFirst = SKPhysicsJointLimit.jointWithBodyA(firstChain.physicsBody!, bodyB: chains[i].physicsBody!,
                    anchorA: getInScene(firstChain.position),
                    anchorB: getInScene(chains[i].position))
                
                limJointWithFirst.maxLength = firstChain.position.y - chains[i].position.y;
                               
                scene!.physicsWorld.addJoint(limJointWithHook)
                scene?.physicsWorld.addJoint(pinJointWithOther)
                scene?.physicsWorld.addJoint(limJointWithFirst)
            }
            
            
            if chains[i].name == "hook"
            {
                let limJoint = SKPhysicsJointLimit.jointWithBodyA(firstChain.physicsBody!, bodyB: hookNode.physicsBody!,
                    anchorA: getInScene(CGPoint(x: firstChain.position.x, y: CGRectGetMaxY(firstChain.frame))),
                    anchorB: getInScene(CGPoint(x:position.x, y: CGRectGetMinY(lastChain.frame))))
                
                limJoint.maxLength = CGRectGetMaxY(firstChain.frame) - CGRectGetMinY(lastChain.frame)
                
                let fixJoint = SKPhysicsJointPin.jointWithBodyA(lastChain.physicsBody!, bodyB: hookNode.physicsBody!,
                    anchor: getInScene(CGPoint(x: position.x, y: lastChain.position.y - lastChain.size.height/2 )))
                
                scene?.physicsWorld.addJoint(fixJoint)
                scene?.physicsWorld.addJoint(limJoint)
            }
        }
    }
    
    func getInScene(point: CGPoint) -> CGPoint
    {
        if let scene = scene {
        let pointInScene =  (scene as! GameScene).convertPoint(point, fromNode: self)
        return pointInScene
        }
        return CGPoint();
    }

    
    func updateState()
    {
   
        if hookNode.physicsBody!.dynamic == false
        {
            currentState = .UnderControll
            
        }else{
            
           if scene != nil
           {
            let inScene = (scene as! GameScene).convertPoint(hookNode.position, fromNode: (scene as! GameScene).chain)
            let inHero = (scene as! GameScene).convertPoint(inScene, toNode: (scene as! GameScene).backgroundLayer)
            
           
           
                    if self.hookNode.physicsBody!.velocity.length() < _maxVelocityHook && abs(hookNode.physicsBody!.angularVelocity) < _maxAngularVelocityHook
                        {
                                currentState = .Stopped
               
                
                            
                                if self.build.number != (scene as! GameScene).hero.build.number && (scene as! GameScene).status  != .Wait
                                    {
                                            let targetPosition =
                                        (scene as! GameScene).convertPoint((scene as! GameScene).convertPoint(hookNode.position, fromNode: (scene as! GameScene).chain), toNode: (scene as! GameScene).backgroundLayer)
                                            if build.number != (scene as! GameScene).hero.build.number
                                                {
                                                        (scene as! GameScene).hero.jump(targetPosition)
                                                        
                                                    
                                                        (scene as! GameScene).runOneTime = false
                                                        (scene as! GameScene).spawnChainOneTime = true
                                                }
                                    }
                
                        }
            

            
            else
            {
                currentState = .InFly
            }
            
        }
            else
           {
            return
            }
        }
        
    }

} // class end