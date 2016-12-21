//
//  CTFDelayDiscountingStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/20/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import Bricoleur
import ResearchKit
import Gloss

class CTFDelayDiscountingStepGenerator: BCLBaseStepGenerator {
    
    public init(){}
    
    let _supportedTypes = [
        "CTFDelayedDiscountingActiveStep"
    ]
    
    public var supportedTypes: [String]! {
        return self._supportedTypes
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: BCLStepBuilderHelper) -> ORKStep? {
        
        guard let customStepDescriptor = helper.getCustomStepDescriptor(forJsonObject: jsonObject),
            let parameters = customStepDescriptor.parameters,
            let stepParamDescriptor = CTFDelayDiscountingParamsDescriptor(json: parameters ) else {
                return nil
        }
        
        let stepParams = CTFDelayDiscountingStepParams(maxAmount: stepParamDescriptor.maxAmount, numQuestions: stepParamDescriptor.numQuestions, nowDescription: stepParamDescriptor.nowDescription, laterDescription: stepParamDescriptor.laterDescription, formatString: stepParamDescriptor.formatString, prompt: stepParamDescriptor.prompt)
        
        let step = CTFDelayDiscountingStep(identifier: customStepDescriptor.identifier)
        step.params = stepParams
        return step
    }
    
    open func processStepResult(type: String,
                                jsonObject: JsonObject,
                                result: ORKStepResult,
                                helper: BCLStepBuilderHelper) -> JSON? {
        return nil
    }
    
}
