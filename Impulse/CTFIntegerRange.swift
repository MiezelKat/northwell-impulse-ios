//
//  CTFIntegerRange.swift
//  Impulse
//
//  Created by James Kizer on 10/7/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import BridgeAppSDK

//public protocol SBANumberRange: class {
//    var minNumber: NSNumber? { get }
//    var maxNumber: NSNumber? { get }
//    var unitLabel: String? { get }
//    var stepInterval: Int { get }
//}

class CTFIntegerRange: NSObject, SBANumberRange {

    var minValue: Int?
    var maxValue: Int?
    var unitLabel: String?
    var interval: Int?
    
    var minNumber: NSNumber? {
        guard let minValue = self.minValue
            else {
            return nil
        }
        return NSNumber(value: minValue)
    }
    
    var maxNumber: NSNumber? {
        guard let maxValue = self.maxValue
            else {
                return nil
        }
        return NSNumber(value: maxValue)
    }
    
    var stepInterval: Int {
        return self.interval ?? 0
    }
    
    
    
}
