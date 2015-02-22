//
//  Building.swift
//  EscapeGame
//
//  Created by admin on 05.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import SpriteKit



func randomFloat(lowerLimit: CGFloat, upperLimit: CGFloat) -> CGFloat
{
    return  ( CGFloat(arc4random()) / CGFloat(UInt32.max) ) * (upperLimit - lowerLimit) + lowerLimit
    
}


var i = 0;

class Build: SKSpriteNode
 {
     var antenna : SKSpriteNode = SKSpriteNode(imageNamed: "antenna")
     var number: Int = 0
  override init()
  {
    super.init(texture: SKTexture(imageNamed: "build2"),color : UIColor.clearColor(), size: SKTexture(imageNamed: "build").size())
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
    

  convenience init(posY: CGFloat, minHeight: CGFloat, maxHeight: CGFloat, minWidth: CGFloat, maxWidth: CGFloat)
    {
        self.init()
        let randSize = CGSize(width: randomFloat(minWidth, maxWidth), height: randomFloat(minHeight, maxHeight))
        self.size = randSize
       
        
        self.position = CGPoint(x: 0, y: posY + self.size.height/2 )
        self.name = "build"
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.frame.size)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Build
        self.physicsBody!.collisionBitMask = PhysicsCategory.Chain | PhysicsCategory.Hook
        self.physicsBody!.affectedByGravity = true
        self.physicsBody!.mass = 999999999
        self.physicsBody!.friction = 999
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Edge
        antenna.position = CGPoint(x: 0, y: self.size.height/2 + self.antenna.size.height/2)
        antenna.setScale(3.5)
        
//        antenna.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "antenna"), size: antenna.size)
//        antenna.physicsBody!.categoryBitMask = PhysicsCategory.Antenna
//        antenna.physicsBody!.collisionBitMask = PhysicsCategory.Hook | PhysicsCategory.Build
//        antenna.physicsBody!.mass = 999999999
        number = i
        i++
//        self.addChild(antenna)
        
        
        
    }
    
    func end() -> CGPoint
    {
        return CGPoint(x: self.position.x + size.width/2, y: self.position.y + size.height/2)
    }
    
    func fixJointAntenn()
    {
//         let fixJoint = SKPhysicsJointFixed.jointWithBodyA(self.antenna.physicsBody, bodyB: self.physicsBody, anchor: CGPointZero)
//        scene?.physicsWorld.addJoint(fixJoint)
}
}
