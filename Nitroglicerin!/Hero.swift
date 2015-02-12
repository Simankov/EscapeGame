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
        super.init(texture: SKTexture(imageNamed: "hero"), color: UIColor.clearColor(), size: CGSize(width: 150, height: 150))
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Hero
        self.physicsBody!.collisionBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
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
    func updatePosition()
    {
        cannon.position = self.position
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
        self.physicsBody!.velocity = CGVectorMake(200, 200)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}