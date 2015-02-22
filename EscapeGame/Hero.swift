//
//  Hero.swift
//  EscapeGame
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
        case Fly = "Fly"
      
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
        case In = 4;
    }
    
    var chain = Chain()
    var powerMultiple : CGFloat = 0
    var state : State = .Stand
    var build: Build = Build()
    var animationBreath: [SKTexture] = [SKTexture]()
    var intersect : Intersect = .None
    
    override init()
    {
        super.init(texture: SKTexture(imageNamed: "hero"), color: UIColor.clearColor(), size: SKTexture(imageNamed: "hero").size())
       
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(size.width*0.85, size.height))
        self.physicsBody!.categoryBitMask = PhysicsCategory.Hero
        self.physicsBody!.collisionBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Build
        self.physicsBody!.allowsRotation = true
        self.physicsBody!.mass = 19999
        
        self.xScale = 1.3
        self.yScale = 1.2
    
        self.animationBreath.append(SKTexture(imageNamed: "heroStand"))
        self.animationBreath.append(SKTexture(imageNamed: "heroBreath"))
       
    }
    
    
    func addJointWithChain()
    {
        let gameScene = scene as GameScene
        gameScene.chain.firstChain.physicsBody!.dynamic = true
        gameScene.chain.firstChain.position = gameScene.convertPoint(gameScene.convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2 + 30), fromNode: gameScene.backgroundLayer), toNode: chain)
        gameScene.chain.firstChain.zRotation = CGFloat(M_PI_2);
        
        let pinJoint = SKPhysicsJointFixed.jointWithBodyA(self.physicsBody, bodyB: gameScene.chain.firstChain.physicsBody, anchor: gameScene.convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2 + 30), fromNode: gameScene.backgroundLayer))
        scene?.physicsWorld.addJoint(pinJoint)
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
        
        let targetVector = CGVectorMake(target.x - hookPosition.x, target.y - hookPosition.y)
        let targetDirection = targetVector.normalize()
        let impulse = CGVectorMake(targetDirection.dx * powerMultiple * 4000, targetDirection.dy * powerMultiple * 4000)
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
        } else {
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
                    amount = size.width
                case .Right :
                    amount = -size.height/2
                case .In:
                    amount = abs(self.position.x - CGRectGetMaxX(build.frame))
                default:
                    amount = 0
            }
            
            let g : CGFloat = 9.8
            let x1 = self.position.x
            let y1 = self.position.y
            let timeOfJump : CGFloat = 1
            let x2 = target.x + amount
            let y2 = target.y + self.size.height/2
            var sign : CGFloat = 1
            
            if (x2-x1) + (y1-y2) < 0
            {
                sign = -1
            }
            
            let distance = (x2-x1)/157 + (y1-y2)/157
            
             
            let time = sqrt(( sign * distance * 2 / g ))
            let Vox = (x2 - x1) / time
           
            self.physicsBody!.velocity = CGVectorMake(Vox, sign * Vox)
            self.animate(.BeginJump)
        }
    
    }

    func updateState()
    {
        if physicsBody!.velocity.length() > 0.1
        {
            self.state = .Fly
            
        }
        else
        {
            self.state = .Stand
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}