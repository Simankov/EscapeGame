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
        case Loose = "Loose"
      
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
    var basket = SKSpriteNode()
    var power : CGFloat = 300
   
    
    init()
    {
        super.init(texture: SKTexture(imageNamed: "hero"), color: UIColor.clearColor(), size: SKTexture(imageNamed: "hero").size())
       
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(size.width*0.85, size.height))
        self.physicsBody!.categoryBitMask = PhysicsCategory.Hero
        self.physicsBody!.collisionBitMask = PhysicsCategory.Build | PhysicsCategory.Edge
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Build
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.mass = 199999
        self.zPosition = 1000
        
        self.size = SKTexture(imageNamed: "heroStand").size()
       
        
   
        self.animationBreath.append(SKTexture(imageNamed: "heroStand"))
        self.animationBreath.append(SKTexture(imageNamed: "heroBreath"))
       
    }
    
    
    func addJointWithChain()
    {
        
        (scene as! GameScene).chain.firstChain.physicsBody!.dynamic = true
        (scene as! GameScene).chain.firstChain.position = (scene as! GameScene).convertPoint((scene as! GameScene).convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2 + 30), fromNode: (scene as! GameScene).backgroundLayer), toNode: chain)
        (scene as! GameScene).chain.firstChain.zRotation = CGFloat(M_PI_2);
        
        let pinJoint = SKPhysicsJointFixed.jointWithBodyA(self.physicsBody!, bodyB: (scene as! GameScene).chain.firstChain.physicsBody!, anchor: (scene as! GameScene).convertPoint(CGPointMake(self.position.x, self.position.y - self.frame.height/2 + 30), fromNode: (scene as! GameScene).backgroundLayer))
        scene?.physicsWorld.addJoint(pinJoint)
    }
    
    func addBasket()
    {
      
        basket.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "maskForBasket"), size: CGSize(width: self.size.width*1.3, height: self.size.height * 1.5))
        basket.physicsBody!.categoryBitMask = PhysicsCategory.Busket
        
        
        self.addChild(basket)
        
        
        
    }

    
    func shot(target: CGPoint)
    {
        powerMultiple += 0.4
        powerMultiple = powerMultiple * powerMultiple
        if powerMultiple > _maxTimeOfPress
        {
            powerMultiple = _maxTimeOfPress
        }
        
        let hookPosition =
        (scene as! GameScene).convertPoint(
        (scene as! GameScene).convertPoint(chain.hookNode.position, fromNode: chain),
            toNode: (scene as! GameScene).backgroundLayer)
        
        let targetVector = CGVectorMake(target.x - hookPosition.x, target.y - hookPosition.y)
        let targetDirection = targetVector.normalize()
        let max = 1200 * chain.hookNode.physicsBody!.mass
        let perTime = ( max / 1.5 )
        let impulse = CGVectorMake(targetDirection.dx * perTime * powerMultiple , targetDirection.dy * perTime * powerMultiple)
        let gameScene = scene as! GameScene
        chain.changeCollisionMaskForChains()
        let positionInScene = gameScene.convertPoint(gameScene.chain.hookNode.position, fromNode: gameScene.chain)
        let positionInBack = gameScene.convertPoint(positionInScene, toNode: gameScene.backgroundLayer)
        
        if CGRectIntersectsRect(gameScene.chain.build.frame, CGRect(origin: CGPointMake(positionInBack.x - gameScene.chain.hookNode.size.width/2 - 25, positionInBack.y - gameScene.chain.hookNode.size.height/2 - 25), size: CGSizeMake(chain.hookNode.size.width + 50,chain.hookNode.size.height + 50 ))) && (build.number == chain.build.number)
        {
           chain.hookNode.physicsBody!.applyImpulse(impulse)
            gameScene.isApplied = true
        }
        
        powerMultiple = 0;
    }
    
    func animate(current: Animate)
    {
        if current == .BeginJump
        {
            self.texture = SKTexture(imageNamed: "heroJump")
            self.removeActionForKey("breath")
        } else {
            let action = SKAction.repeatActionForever((SKAction.animateWithTextures(self.animationBreath, timePerFrame: 0.5)))
            self.texture = SKTexture(imageNamed: "heroStand")
            self.runAction(action, withKey : "breath")
        }
    }
    
    func jump(target: CGPoint)
    {
        if self.physicsBody!.velocity.length() < 0.1         {
            
            (scene as! GameScene?)?.sound(.Jump)
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
            
            let g : CGFloat = abs((scene as! GameScene).physicsWorld.gravity.dy)
            let x1 = self.position.x
            let y1 = self.position.y
            let timeOfJump : CGFloat = 1
            var x2 = target.x
            let y2 = target.y + self.size.height/2
            
        if self.state != .Loose
        {
            if target.x > chain.build.position.x + chain.build.size.width/2 - self.size.width/2
            {
                x2 = chain.build.position.x + chain.build.size.width/2 - self.size.width/2
            }
            
            if target.x < chain.build.position.x - chain.build.size.width/2 + self.size.width/2
            {
                x2 = chain.build.position.x - chain.build.size.width/2 + self.size.width/2
            }
        }
           
           
            self.physicsBody!.velocity = calculateSpeed(CGPointMake(x1, y1), target: CGPointMake(x2, y2))
            self.animate(.BeginJump)
        }
    
    }
    
    func calculateSpeed(start: CGPoint, target: CGPoint) -> CGVector
    {
        let g : CGFloat = abs((scene as! GameScene).physicsWorld.gravity.dy)
        let x1 = start.x
        let y1 = start.y
        let x2 = target.x
        let y2 = target.y
        var sign : CGFloat = 1
        
        if (x2-x1) + (y1-y2) < 0
        {
            sign = -1
        }
        
        let distance = (x2-x1)/_pointsInMeter + (y1-y2)/_pointsInMeter
        
        
        let time = sqrt(( sign * distance * 2 / g ))
        let Vox = (x2 - x1) / time
        
        return CGVectorMake(Vox, sign * Vox)
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