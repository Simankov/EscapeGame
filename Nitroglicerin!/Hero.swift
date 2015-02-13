//
//  Hero.swift
//  Nitroglicerin!
//
//  Created by admin on 07.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import SpriteKit

class Hero : SKSpriteNode
{
    enum State{
        case Stand
        case Run
        case Shot
        case Fly
        case OnBlock
    }
    let jumpPover : CGFloat = 50
    let cannon = Cannon()
    var state : State = .Stand
    override init()
    {
        super.init(texture: SKTexture(imageNamed: "hero"), color: UIColor.clearColor(), size: CGSize(width: 90, height: 90))
       
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Hero
        self.physicsBody!.collisionBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Build
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.mass = 1999
        self.physicsBody!.friction = 0
        cannon.position = self.position
        cannon.zPosition = 3
        self.setScale(2)
        
        
        
    }
    func addJoint()
    {
        
        let gameScene = scene as GameScene
        let pinJoint = SKPhysicsJointPin.jointWithBodyA(self.physicsBody, bodyB: cannon.physicsBody, anchor: gameScene.convertPoint(self.position, fromNode: gameScene.backgroundLayer))
        scene?.physicsWorld.addJoint(pinJoint)
    }
    
    func climb(target: CGPoint)
    {
        self.runAction(SKAction.moveTo(target, duration: 0.5))
    }
    
    func run(target: CGPoint)
    {
        if self.state == .Fly {
        self.runAction(SKAction.moveTo(target, duration: 0.5))
        state = .Run
        }
    }
    func jump(target: CGPoint)
    {
    if self.physicsBody!.velocity.length() < 0.1
    {
        let g : CGFloat = 9.8
        let x1 = self.position.x
        let y1 = self.position.y
        let timeOfJump : CGFloat = 1
        let x2 = target.x
        let y2 = target.y + self.frame.height/2
        
        if (x2-x1) + (y1-y2) < 0
        {
            return
        }
        
         
       let time = sqrt(( (x2-x1)/150 + (y1-y2)/150 ) * 2 / g )
       let Vox = (x2 - x1) / time
      
        self.physicsBody!.velocity = CGVectorMake(Vox, Vox)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}