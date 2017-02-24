//
//  CTFSemanticDifferentialScaleFormItemDecriptor.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import Gloss
import ResearchSuiteTaskBuilder

class CTFSemanticDifferentialScaleFormItemDecriptor: RSTBStepDescriptor {
    
    let minimum: Int
    let maximum: Int
    let defaultValue: Int
    let step: Int
    let minValueText: String
    let maxValueText: String
    let trackHeight: CGFloat
    let gradientColors: [UIColor]?
    
    required public init?(json: JSON) {
        
        guard let min: Int = "range.min" <~~ json,
            let max: Int = "range.max" <~~ json,
            let defaultValue: Int = "range.default" <~~ json,
            let step: Int = "range.step" <~~ json,
            let minText: String = "range.minValueText" <~~ json,
            let maxText: String = "range.maxValueText" <~~ json else {
                return nil
        }
        
        self.minimum = min
        self.maximum = max
        self.defaultValue = defaultValue
        self.step = step
        self.minValueText = minText
        self.maxValueText = maxText
        self.trackHeight = "range.trackHeight" <~~ json ?? 4.0
        if let gradientColorString: [String] = "range.gradientColors" <~~ json {
            self.gradientColors = gradientColorString.flatMap({ (colorString) -> UIColor? in
                return UIColor(hexString: colorString)
            })
        }
        else {
            self.gradientColors = nil
        }
        
        super.init(json: json)
        
    }
}
