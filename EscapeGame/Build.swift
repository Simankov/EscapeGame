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


var _countOfBuilds = 0;

class Build: SKSpriteNode
 {
     var antenna : SKSpriteNode = SKSpriteNode(imageNamed: "antenna")
     var number: Int = 0
 init()
  {
    super.init(texture: SKTexture(imageNamed: "build2"),color : UIColor.clearColor(), size: SKTexture(imageNamed: "build2").size())
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
    

    convenience init(posY: CGFloat, size: CGSize)
    {
        self.init()
        self.size = size
       
        
        self.position = CGPoint(x: 0, y: posY + self.size.height/2 )
        self.name = "build"
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.frame.size)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Build
        self.physicsBody!.collisionBitMask = PhysicsCategory.Chain | PhysicsCategory.Hook
        self.physicsBody!.affectedByGravity = true
        self.physicsBody!.mass = 999999999
        self.physicsBody!.friction = 1
        self.physicsBody!.contactTestBitMask = PhysicsCategory.Edge
        
//        antenna.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "antenna"), size: antenna.size)
//        antenna.physicsBody!.categoryBitMask = PhysicsCategory.Antenna
//        antenna.physicsBody!.collisionBitMask = PhysicsCategory.Hook | PhysicsCategory.Build
//        antenna.physicsBody!.mass = 999999999
        number = _countOfBuilds
        _countOfBuilds++
//        self.addChild(antenna)
        
        
        
    }
    
    func end() -> CGPoint
    {
        return CGPoint(x: self.position.x + size.width/2, y: self.position.y + size.height/2)
    }
    

}
