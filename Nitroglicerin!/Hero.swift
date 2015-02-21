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
    enum State: String{
        case Stand = "Stand"
        case Run = "Run"
        case Shot = "Shot"
        case Fly = "Fly"
        case OnBlock = "OnBlock"
    }
    enum Animate
    {
        case BeginJump
        case EndJump
    }
    
    enum Intersect: Int
    {
        case None = 1;
        case Left = 2;
        case Right = 3;
    }
    let jumpPover : CGFloat = 50
    var chain = Chain()
    var powerMultiple : CGFloat = 0
    var state : State = .Stand
    var blockNumber = 0
    var build: Build = Build()
    var animationBreath: [SKTexture] = [SKTexture]()
    var intersect : Intersect = .None
    override init()
    {
        super.init(texture: SKTexture(imageNamed: "hero"), color: UIColor.clearColor(), size: CGSize(width: 90, height: 90))
       
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Hero
        self.physicsBody!.collisionBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Build
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.mass = 1999999
        self.physicsBody!.friction = 0
      self.animationBreath.append(SKTexture(imageNamed: "heroStand"))
      self.animationBreath.append(SKTexture(imageNamed: "heroBreath"))
        self.setScale(3)
        
        
        
    }
    func addJointWithChain()
    {
        
        let gameScene = scene as GameScene
        gameScene.chain.firstChain.physicsBody!.dynamic = true
         gameScene.chain.firstChain.position = gameScene.convertPoint(gameScene.convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2 + 30), fromNode: gameScene.backgroundLayer), toNode: chain)
        gameScene.chain.firstChain.zRotation = CGFloat(M_PI_2);
        let pinJoint = SKPhysicsJointFixed.jointWithBodyA(self.physicsBody, bodyB: gameScene.chain.firstChain.physicsBody, anchor: gameScene.convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2 + 30), fromNode: gameScene.backgroundLayer))
//        println(gameScene.convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2), fromNode: gameScene.backgroundLayer))
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
    

    
    func shot(target: CGPoint)
    {
        powerMultiple += 1
        
        let gameScene = scene as GameScene
        let hookPosition =
        gameScene.convertPoint(
        gameScene.convertPoint(chain.hookNode.position, fromNode: chain),
            toNode: gameScene.backgroundLayer)
//        powerMultiple from 16000 to 4000
        
        let targetVector = CGPointMake(target.x - hookPosition.x, target.y - hookPosition.y)
        let targetDirection = normalaized(targetVector)
        let impulse = CGVectorMake(targetDirection.x * powerMultiple * 4000, targetDirection.y * powerMultiple * 4000)
        (scene as GameScene).chain.hookNode.physicsBody!.applyImpulse(impulse)
        //        fire.physicsBody!.applyImpulse(CGVectorMake(direction.x * power * powerMultiple, direction.y * power * powerMultiple))
        powerMultiple = 0;
    }
    func animate(current: Animate)
    {
        if current == .BeginJump
        {
            self.texture = SKTexture(imageNamed: "heroJump")
            self.removeActionForKey("breath")
        }
        else {
            var action = SKAction.repeatActionForever((SKAction.animateWithTextures(self.animationBreath, timePerFrame: 0.5)))
            self.texture = SKTexture(imageNamed: "heroStand")
            self.runAction(action, withKey : "breath")
            
        }
    }
    
    func jump(target: CGPoint)
    {
    if self.physicsBody!.velocity.length() < 0.1
    {
        var amount: CGFloat = 0;
        switch(self.intersect){
        case .None :
           amount = 0
        case .Left :
            amount = size.width/2
        case .Right :
            amount = -size.height/2
        default:
            amount = 0
        }
        
        let g : CGFloat = 9.8
        let x1 = self.position.x
        let y1 = self.position.y
        let timeOfJump : CGFloat = 1
        let x2 = target.x + amount
        let y2 = target.y + self.frame.height/2
        var sign : CGFloat = 1
        if (x2-x1) + (y1-y2) < 0
        {
            sign = -1
        }
        let distance = (x2-x1)/150 + (y1-y2)/150
        
         
       let time = sqrt(( sign * distance * 2 / g ))
       let Vox = (x2 - x1) / time
       
        self.physicsBody!.velocity = CGVectorMake(Vox, sign * Vox)
        self.animate(.BeginJump)
        
    }
    else
    {
        self.state = .Fly
    }
    
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}