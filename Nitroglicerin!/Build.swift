//
//  Building.swift
//  Nitroglicerin!
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


class Build: SKSpriteNode
 {
     var antenna : SKSpriteNode = SKSpriteNode(imageNamed: "antenna")
    
  override init()
  {
    super.init(texture: SKTexture(imageNamed: "build"),color : UIColor.clearColor(), size: SKTexture(imageNamed: "build").size())
    
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
       
        self.addChild(antenna)
        
        
        
    }
    
    func fixJointAntenn()
    {
//         let fixJoint = SKPhysicsJointFixed.jointWithBodyA(self.antenna.physicsBody, bodyB: self.physicsBody, anchor: CGPointZero)
//        scene?.physicsWorld.addJoint(fixJoint)
}
}