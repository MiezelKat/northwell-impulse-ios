//
//  GenericHelpers.swift
//  Impulse
//
//  Created by James Kizer on 10/17/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Foundation

func coinFlip<T>(_ obj1: T, obj2: T, bias: Float = 0.5) -> T {
    
    //ensure bias is in range [0.0, 1.0]
    let realBias: Float = max(min(bias, 1.0), 0.0)
    let flip = Float(arc4random()) /  Float(UInt32.max)
    
    if flip < realBias {
        return obj1
    }
    else {
        return obj2
    }
}
