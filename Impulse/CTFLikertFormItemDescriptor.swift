//
//  CTFLikertFormItemDescriptor.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss

class CTFLikertFormItemDescriptor: RSTBStepDescriptor {
    
    let minimum: Int
    let maximum: Int
    let defaultValue: Int
    let step: Int
    let minValueText: String
    let midValueText: String
    let maxValueText: String
    
    required public init?(json: JSON) {
        
        guard let min: Int = "range.min" <~~ json,
            let max: Int = "range.max" <~~ json,
            let defaultValue: Int = "range.default" <~~ json,
            let step: Int = "range.step" <~~ json,
            let minText: String = "range.minValueText" <~~ json,
            let midText: String = "range.midValueText" <~~ json,
            let maxText: String = "range.maxValueText" <~~ json else {
                return nil
        }
        
        self.minimum = min
        self.maximum = max
        self.defaultValue = defaultValue
        self.step = step
        self.minValueText = minText
        self.midValueText = midText
        self.maxValueText = maxText
        
        super.init(json: json)
        
    }

}
