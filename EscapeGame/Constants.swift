//
//  Constants.swift
//  EscapeGame
//
//  Created by admin on 28.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import SpriteKit

let _maxHeightBuild: CGFloat  = 800
let _minHeightBuild : CGFloat = 100
let _maxWidthBuild: CGFloat  = 600
let _minWidthBuild: CGFloat =  256

let _hookNodeDensity: CGFloat  =  30000 //40000
let _hookNodeScale: CGFloat  = 1.4
let _DistanceFromEdge: CGFloat  =  400
let _backgroundMoveSpeed: CGFloat =  1300
let _maxLenghtBetweenBuilds: CGFloat = 1300  //1500 //
let _minLenghtBetweenBuilds: CGFloat = 900   //900
let _pointsInMeter: CGFloat = 157
let _maxVelocityHook: CGFloat = 13
let _maxAngularVelocityHook: CGFloat = 0.4
let _buildMass: CGFloat  = 999999
let _buildFriction: CGFloat  = 0.4
let _maxTimeOfPress: CGFloat = 1.5
let _countOfChains : Int = 40 //34
let _scaleOfChain : CGFloat = 6


struct PhysicsCategory
{
    static var None: UInt32 = 0
    static var Edge: UInt32 = 1
    static var Chain: UInt32 = 2
    static var Hook : UInt32 = 4
    static var Cannon : UInt32 = 8
    static var Build : UInt32 = 16
    static var Hero : UInt32 = 32
    static var Antenna : UInt32 = 64
    static var Fire : UInt32 = 128
    static var Busket: UInt32 = 256
    
}

