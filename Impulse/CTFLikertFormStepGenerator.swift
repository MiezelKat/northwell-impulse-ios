//
//  CTFLikertFormStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss

class CTFLikertFormStepGenerator: RSTBBaseStepGenerator {
    
    public init(){}
    
    let _supportedTypes = [
        "CTFLikertForm"
    ]
    
    public var supportedTypes: [String]! {
        return self._supportedTypes
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ORKStep? {
        
        guard let customStepDescriptor = helper.getCustomStepDescriptor(forJsonObject: jsonObject),
            let parameters = customStepDescriptor.parameters,
            let likertFormParametersDescriptor = CTFLikertScaleFormParameters(json: parameters ) else {
            return nil
        }
        
        //generate form items from question step descriptors
        let formItems = likertFormParametersDescriptor.items.flatMap { (formItemDescriptor) -> ORKFormItem? in
            
            let answerFormat = CTFLikertScaleAnswerFormat(withMaximumValue: formItemDescriptor.maximum, minimumValue: formItemDescriptor.minimum, defaultValue: formItemDescriptor.defaultValue, step: formItemDescriptor.step, vertical: false, maximumValueDescription: formItemDescriptor.maxValueText, intermediateValueDescription: formItemDescriptor.midValueText, minimumValueDescription: formItemDescriptor.minValueText)
            return ORKFormItem(identifier: formItemDescriptor.identifier, text: formItemDescriptor.text, answerFormat: answerFormat, optional: formItemDescriptor.optional)
            
        }
        let formStep = CTFPulsusFormStep(identifier: customStepDescriptor.identifier, title: likertFormParametersDescriptor.title, text: likertFormParametersDescriptor.text)
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
