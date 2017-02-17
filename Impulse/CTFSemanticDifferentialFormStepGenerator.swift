//
//  CTFSemanticDifferentialFormStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

class CTFSemanticDifferentialFormStepGenerator: RSTBBaseStepGenerator {
    
    public init(){}
    
    let _supportedTypes = [
        "CTFSemanticDifferentialForm"
    ]
    
    public var supportedTypes: [String]! {
        return self._supportedTypes
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStep? {
        
        guard let customStepDescriptor = helper.getCustomStepDescriptor(forJsonObject: jsonObject),
            let parameters = customStepDescriptor.parameters,
            let semanticDifferentialFormParameters = CTFSemanticDifferentialScaleFormParameters(json: parameters ) else {
                return nil
        }
        
        //generate form items from question step descriptors
        let formItems = semanticDifferentialFormParameters.items.flatMap { (formItemDescriptor) -> ORKFormItem? in
            
            let answerFormat = CTFSemanticDifferentialScaleAnswerFormat(withMaximumValue: formItemDescriptor.maximum, minimumValue: formItemDescriptor.minimum, defaultValue: formItemDescriptor.defaultValue, step: formItemDescriptor.step, vertical: false, maximumValueDescription: formItemDescriptor.maxValueText, minimumValueDescription: formItemDescriptor.minValueText, trackHeight: formItemDescriptor.trackHeight, gradientColors: formItemDescriptor.gradientColors)
            return ORKFormItem(identifier: formItemDescriptor.identifier, text: formItemDescriptor.text, answerFormat: answerFormat, optional: formItemDescriptor.optional)
            
        }
        let formStep = CTFPulsusFormStep(identifier: customStepDescriptor.identifier, title: semanticDifferentialFormParameters.title, text: semanticDifferentialFormParameters.text)
        formStep.formItems = formItems
        return formStep
    }
    
    open func processStepResult(type: String,
                                jsonObject: JsonObject,
                                result: ORKStepResult,
                                helper: RSTBTaskBuilderHelper) -> JSON? {
        return nil
    }

}
