//
//  CTFScaleAnswerFormat.swift
//  Impulse
//
//  Created by James Kizer on 11/7/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

enum CTFScaleAnswerType {
    case likert
    case semanticDifferential
}

class CTFScaleAnswerFormat: ORKScaleAnswerFormat {
    var intermediateValueDescription: String?
    
    var scaleType: CTFScaleAnswerType?
    
    convenience init(withMaximumValue scaleMaximum: Int,
         minimumValue scaleMinimum: Int,
         defaultValue: Int,
         step: Int,
         vertical: Bool,
         maximumValueDescription: String?,
         intermediateValueDescription: String?,
         minimumValueDescription: String?,
         scaleAnswerType: CTFScaleAnswerType?){
        
        self.init(maximumValue: scaleMaximum,
                   minimumValue: scaleMinimum,
                   defaultValue: defaultValue,
                   step: step,
                   vertical: vertical,
                   maximumValueDescription: maximumValueDescription,
                   minimumValueDescription: minimumValueDescription)
        
        self.intermediateValueDescription = intermediateValueDescription
        self.scaleType = scaleAnswerType
        
    }
    
}
