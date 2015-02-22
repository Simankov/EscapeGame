//
//  Cannon.swift
//  EscapeGame
//
//  Created by admin on 05.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import SpriteKit


func lenght(vector: CGPoint) -> CGFloat
{
    return sqrt(vector.x * vector.x + vector.y * vector.y)
}

func normalaized(vector: CGPoint) -> CGPoint
{
    return CGPoint(x: vector.x / lenght(vector), y: vector.y / lenght(vector))
}

class Cannon: SKSpriteNode{
    
    enum Status
    {
        case onPosition, inMove, Shot
    }
    
    var firePosition : CGPoint = CGPointZero
    let power: CGFloat = 2000000
    let rotationSpeed : CGFloat = 4 * CGFloat(M_PI)
    var direction: CGPoint = CGPointZero
    var fire = SKSpriteNode(imageNamed: "wood_horiz1")
    var powerMultiple : CGFloat = 0
    var status : Status = Status.onPosition
    override init() {
        super.init(texture: SKTexture(imageNamed: "cannon"), color: UIColor.clearColor(), size: SKTexture(imageNamed: "cannon").size())
       
        let bodyGun = CGPathCreateMutable()
        
        
        CGPathMoveToPoint(bodyGun, nil, self.frame.width/2, -self.frame.height/2)
        CGPathAddLineToPoint(bodyGun, nil, -self.frame.width/2, -self.frame.height/2)
        CGPathAddLineToPoint(bodyGun, nil, -self.frame.width/2, self.frame.height/2)
        CGPathAddLineToPoint(bodyGun, nil, self.frame.width/2, self.frame.height/2)
        self.physicsBody = SKPhysicsBody(edgeChainFromPath: bodyGun)
        self.physicsBody!.mass = 99999
        self.physicsBody?.collisionBitMask =  PhysicsCategory.Hook | PhysicsCategory.Fire
        self.physicsBody?.categoryBitMask = PhysicsCategory.Cannon
        
        
        self.zPosition = 0.5
        
       
        fire.size = CGSize(width: self.size.height-2, height: self.size.height-2 )
        fire.name = "fire"
        fire.physicsBody = SKPhysicsBody(rectangleOfSize: fire.size)
        fire.position = CGPoint(x:0, y:0)
        firePosition = fire.position
        
        fire.physicsBody!.mass = 9999;
        fire.physicsBody!.categoryBitMask = PhysicsCategory.Fire
        fire.physicsBody!.collisionBitMask = PhysicsCategory.Hook | PhysicsCategory.Cannon
        self.addChild(fire)
        fire.physicsBody!.affectedByGravity = false
        self.setScale(5)
        self.zRotation = CGFloat(M_PI_4)
        
       
    }
    
    func shot(offset : CGPoint)
    {
       powerMultiple += 1
       powerMultiple = powerMultiple * powerMultiple
      
            
                
        
            
        self.status = .Shot
        (scene as GameScene).chain.hookNode.physicsBody!.applyImpulse(CGVectorMake(1700/1.4, 1700/1.4))
//        fire.physicsBody!.applyImpulse(CGVectorMake(direction.x * power * powerMultiple, direction.y * power * powerMultiple))
//        println((self.scene as GameScene).chain.hookNode.physicsBody!.velocity.length())
//              fire.runAction(SKAction.sequence([SKAction.waitForDuration(0.3), SKAction.runBlock({
//            println((self.scene as GameScene).chain.hookNode.physicsBody!.velocity.length())
//            self.fire.removeFromParent()
//            self.fire.position = self.firePosition
//            self.addChild(self.fire)
//           
//        })]))
    
       
    
    }
    convenience init(position: CGPoint)
    {
        self.init()
        self.position = position
    }
    
    func rotateToPosition(target: CGPoint)
    {
        let gameScene = scene! as GameScene
    
        let positionInBakground = self.position
        
        let newTarget = CGPointMake(target.x - positionInBakground.x, target.y - positionInBakground.y)
        var targetDirection = normalaized(newTarget)
        
       
        let pointStart = gameScene.convertPoint(CGPoint(x: self.size.width/2, y: 0), fromNode: self)
        let pointEnd = gameScene.convertPoint(CGPoint(x: -self.size.width/2, y: 0), fromNode: self)
        
        let pointStartInBackground = gameScene.convertPoint(pointStart, toNode: gameScene.backgroundLayer)
        let pointEndInBackground = gameScene.convertPoint(pointEnd, toNode: gameScene.backgroundLayer)
        
        
        let offset = CGPointMake(pointStartInBackground.x - pointEndInBackground.x, pointStartInBackground.y - pointEndInBackground.y)
        
        direction = normalaized(offset)
        var angleDirection = acos(direction.x )
        let sign : CGFloat = (targetDirection.y > direction.y) ? 1 : -1
        
        var angle = acos(targetDirection.x ) * sign
        if angle <= 0 && angle >= -3 * CGFloat(M_PI / 4)  || angle >= 5 * CGFloat(M_PI / 4)
        {
            angle = 0
            targetDirection = CGPointMake(1, 0)
        }
        
        if angle  <= -3 * CGFloat(M_PI / 4)  || angle >= CGFloat(M_PI_2) && angle <= 5 * CGFloat(M_PI / 4)

        {
            angle = CGFloat(M_PI_2)
            targetDirection = CGPointMake(0, 1)
        }
        let angleBetween = abs(acos(targetDirection.x * direction.x + targetDirection.y * direction.y))
//        let angleBetween = abs(angle - angleDirection)
        
        let amount = gameScene.dt * rotationSpeed * sign
       
        if abs(amount) >= angleBetween
        {
            self.zRotation = angle
            self.status = .onPosition
            
        }
        else
        {
            self.zRotation += amount
            self.status = .inMove
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}