//
//  Extensions.swift
//  Nitroglicerin!
//
//  Created by admin on 08.02.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import SpriteKit

extension CGVector
{
    func length() -> CGFloat
    {
        return sqrt(self.dx * self.dx + self.dy * self.dy)
    }
}

