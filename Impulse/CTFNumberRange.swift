//
//  CTFNumberRange.swift
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

//consider using 
//https://github.com/Hearst-DD/ObjectMapper/

class CTFNumberRange: NSObject, SBANumberRange {
    var _min: NSNumber?
    var _max: NSNumber?
    var _default: NSNumber?
    var _step: NSNumber?
    var _minValueText: String?
    var _maxValueText: String?
    var _unitLabel: String?
    
    var minNumber: NSNumber? {
        return self._min
    }
    
    var maxNumber: NSNumber? {
        return self._max
    }
    
    var unitLabel: String? {
        return self._unitLabel
    }
    
    var stepInterval: Int {
        return self._step?.intValue ?? 0
    }
    
    init(with dictionary: AnyObject) {
        self._min = dictionary["min"] as? NSNumber
        self._max = dictionary["max"] as? NSNumber
        self._default = dictionary["default"] as? NSNumber
        self._step = dictionary["step"] as? NSNumber
        self._minValueText = dictionary["minValueText"] as? String
        self._maxValueText = dictionary["maxValueText"] as? String
        self._unitLabel = dictionary["unitLabel"] as? String
    }
}
