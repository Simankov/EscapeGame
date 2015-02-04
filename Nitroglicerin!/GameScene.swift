//
//  GameScene.swift
//  Nitroglicerin!
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
}

class GameScene: SKScene{
var playableArea: CGRect = CGRect()
var bottle: SKSpriteNode = SKSpriteNode()
    var touchedNode : SKNode? = SKNode()
    var hookNode: SKShapeNode = SKShapeNode()
    var last = SKNode()
    var firstChain = SKNode()

    var startPosition : CGPoint = CGPointZero;
    var endPosition: CGPoint = CGPointZero
    var background: SKSpriteNode = SKSpriteNode()

   override func didMoveToView(view: SKView) {
    let maxAspectRatio : CGFloat = 16/9;
    let maximumHeight = size.width / maxAspectRatio
    let margin = (size.height - maximumHeight) / 2
    bottle = childNodeWithName("bottle") as SKSpriteNode;
    bottle.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mask"), size: CGSize(width: bottle.size.width, height: bottle.size.height))
    background = childNodeWithName("background") as SKSpriteNode
    playableArea = CGRect(x: 0, y: margin+100, width: size.width, height: maximumHeight)
    self.physicsBody = SKPhysicsBody(edgeLoopFromRect: playableArea)
    self.physicsBody!.categoryBitMask = PhysicsCategory.Edge
    self.physicsBody!.collisionBitMask = PhysicsCategory.Chain | PhysicsCategory.Edge | PhysicsCategory.Hook
    
    view.showsPhysics = false
    bottle.physicsBody!.restitution = 0.3
    bottle.physicsBody!.density = 0.7
    createСhain(CGPoint(x: size.width/2, y: playableArea.height), length: 200, countSubChaines: 80)
       
   background.name = "scene"
    
    
    
    
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        
        
        startPosition = (touches.anyObject() as UITouch).locationInNode(self)
       
    touchedNode  = nodeAtPoint(startPosition) as SKNode?
        let vadd = 0
        
    }
    func applyImpulseToBottle(offset: CGPoint)
    {
        
       
            let bottle2 = last
        
        let offsetVector = CGVectorMake(offset.x, offset.y)
        let position  = scene?.convertPoint(startPosition, toNode: bottle2)
        let emitter = SKEmitterNode(fileNamed: "MyParticle")
        bottle2.physicsBody!.applyForce(offsetVector, atPoint: position!)
        emitter.position = position!
        bottle2.addChild(emitter)
        
        let action = SKAction.sequence([SKAction.runBlock({  emitter.resetSimulation()}),SKAction.waitForDuration(0.1),SKAction.removeFromParent()])
        emitter.runAction(action)

        
    }
    func createСhain(start: CGPoint, length: Int, countSubChaines: Int)
    {
        var rings : [SKShapeNode] = [SKShapeNode]()
        let ringTexture = SKTexture(imageNamed: "ring")
        let height = ringTexture.size().height

        var subChainLenght: CGFloat = CGFloat(length) / CGFloat(countSubChaines) * 2
        var startPosition: CGFloat = 0
        var lastSize: CGFloat = 8
         var first = SKShapeNode()
        
        for i in 0...countSubChaines-1 {
            if i == countSubChaines-1
            {
                subChainLenght = subChainLenght*10
            }
         
        let ringNode = SKShapeNode()
            ringNode.position = CGPoint(x: start.x, y: start.y - startPosition)
            let ring = CGPathCreateMutable()
            let body = CGPathCreateMutable()
            CGPathAddEllipseInRect(ring, nil, CGRect(x: position.x, y: position.y, width: subChainLenght, height: subChainLenght))
            
            CGPathMoveToPoint(body, nil, position.x + subChainLenght, position.y)
            CGPathAddLineToPoint(body, nil, position.x + subChainLenght, position.y + CGFloat(subChainLenght))
            CGPathAddLineToPoint(body, nil, position.x, position.y + CGFloat(subChainLenght))
            CGPathAddLineToPoint(body, nil, position.x, position.y)
            CGPathAddLineToPoint(body, nil, position.x + subChainLenght, position.y)

            
            ringNode.path = ring
            ringNode.physicsBody = SKPhysicsBody(polygonFromPath:  ring)
            ringNode.physicsBody?.density = 1
//            ringNode.physicsBody?.dynamic = false
            ringNode.fillColor = UIColor.blackColor()
            ringNode.strokeColor = UIColor.blackColor()
            ringNode.physicsBody!.categoryBitMask = PhysicsCategory.Chain
            ringNode.physicsBody!.collisionBitMask =   PhysicsCategory.Edge
            
            
            if (i == 0)
            {
                firstChain = ringNode
                ringNode.physicsBody!.dynamic = true
            }
            
            
            ringNode.zPosition = 1;
        addChild(ringNode)
            if i>0 && i != countSubChaines-1 {
                
                let pinJoint = SKPhysicsJointPin.jointWithBodyA(last.physicsBody!, bodyB: ringNode.physicsBody!, anchor: CGPoint(x: start.x , y: start.y - startPosition + lastSize / 2  ))
                let ropeJoint = SKPhysicsJointLimit.jointWithBodyA(firstChain.physicsBody!, bodyB: ringNode.physicsBody!, anchorA:  firstChain.position, anchorB: ringNode.position)
                ropeJoint.maxLength = subChainLenght * CGFloat(i)
                pinJoint.upperAngleLimit = CGFloat(M_PI / 6)
                pinJoint.lowerAngleLimit = CGFloat(-M_PI / 6)
                
              
                pinJoint.shouldEnableLimits = true
                
                physicsWorld.addJoint(pinJoint)
                physicsWorld.addJoint(ropeJoint)
            
            }
            
           else if i == countSubChaines - 1
            {
                
             
                let pinJoint = SKPhysicsJointPin.jointWithBodyA(last.physicsBody!, bodyB: ringNode.physicsBody!, anchor: CGPoint(x: start.x , y: start.y - startPosition + lastSize / 2 ))

                let ropeJoint = SKPhysicsJointLimit.jointWithBodyA(firstChain.physicsBody!, bodyB: ringNode.physicsBody!, anchorA:  firstChain.position, anchorB: ringNode.position)
                ropeJoint.maxLength = CGFloat(i-1) * subChainLenght/10
               physicsWorld.addJoint(ropeJoint)
                physicsWorld.addJoint(pinJoint)
                ringNode.physicsBody!.density = 99
                ringNode.name = "Hook"
                ringNode.physicsBody!.categoryBitMask = PhysicsCategory.Hook
                
                ringNode.physicsBody!.collisionBitMask =  PhysicsCategory.Edge
                hookNode = ringNode
                
            }
        rings.append(ringNode)
        startPosition += CGFloat(subChainLenght) ;
        last = ringNode
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        }
        
        
        for ring in rings
        {
            if ring.name != "Hook"
            {
                
                let ropeJoint = SKPhysicsJointLimit.jointWithBodyA(last.physicsBody!, bodyB: ring.physicsBody!, anchorA:  last.position, anchorB: ring.position)
                ropeJoint.maxLength = ring.position.y - last.position.y
                physicsWorld.addJoint(ropeJoint)
            }
        }
    }

    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        endPosition = (touches.anyObject() as UITouch).locationInNode(self)
        let offset = CGPointMake(endPosition.x - startPosition.x, endPosition.y - startPosition.y)
        applyImpulseToBottle(offset)
        firstChain.physicsBody!.dynamic = false
        
        if touchedNode!.name != "scene" {
        touchedNode?.runAction(SKAction.moveTo(endPosition, duration: 0.5))
        }
        
    }

    
}
