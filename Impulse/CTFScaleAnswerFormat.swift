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
    
    var _scaleType: CTFScaleAnswerType?
    var scaleType: CTFScaleAnswerType? {
        return self._scaleType
    }
    var trackHeight: CGFloat?
    
    convenience init(withMaximumValue scaleMaximum: Int,
         minimumValue scaleMinimum: Int,
         defaultValue: Int,
         step: Int,
         vertical: Bool,
         maximumValueDescription: String?,
         intermediateValueDescription: String?,
         minimumValueDescription: String?,
         scaleAnswerType: CTFScaleAnswerType?,
         trackHeight: CGFloat?){
        
        self.init(maximumValue: scaleMaximum,
                   minimumValue: scaleMinimum,
                   defaultValue: defaultValue,
                   step: step,
                   vertical: vertical,
                   maximumValueDescription: maximumValueDescription,
                   minimumValueDescription: minimumValueDescription)
        
        self.intermediateValueDescription = intermediateValueDescription
        self._scaleType = scaleAnswerType
        self.trackHeight = trackHeight
        
    }
    
}

class CTFLikertScaleAnswerFormat: CTFScaleAnswerFormat {
    override var scaleType: CTFScaleAnswerType? {
        return CTFScaleAnswerType.likert
    }
    
    convenience init(withMaximumValue scaleMaximum: Int,
                     minimumValue scaleMinimum: Int,
                     defaultValue: Int,
                     step: Int,
                     vertical: Bool,
                     maximumValueDescription: String?,
                     intermediateValueDescription: String?,
                     minimumValueDescription: String?){
        
        self.init(maximumValue: scaleMaximum,
                  minimumValue: scaleMinimum,
                  defaultValue: defaultValue,
                  step: step,
                  vertical: vertical,
                  maximumValueDescription: maximumValueDescription,
                  minimumValueDescription: minimumValueDescription)
        
        self.intermediateValueDescription = intermediateValueDescription
        self.trackHeight = 4.0
        
    }
}

class CTFSemanticDifferentialScaleAnswerFormat: CTFScaleAnswerFormat {
    override var scaleType: CTFScaleAnswerType? {
        return CTFScaleAnswerType.semanticDifferential
    }
    
    convenience init(withMaximumValue scaleMaximum: Int,
                     minimumValue scaleMinimum: Int,
                     defaultValue: Int,
                     step: Int,
                     vertical: Bool,
                     maximumValueDescription: String?,
                     minimumValueDescription: String?,
                     trackHeight: CGFloat?,
                     gradientColors: [UIColor]?){
        
        self.init(maximumValue: scaleMaximum,
                  minimumValue: scaleMinimum,
                  defaultValue: defaultValue,
                  step: step,
                  vertical: vertical,
                  maximumValueDescription: maximumValueDescription,
                  minimumValueDescription: minimumValueDescription)
        
        self.intermediateValueDescription = intermediateValueDescription
        self.trackHeight = trackHeight
        self.gradientColors = gradientColors
        
    }
}
