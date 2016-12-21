//
//  CTFBARTStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/20/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import Bricoleur
import ResearchKit
import Gloss

class CTFBARTStepGenerator: BCLBaseStepGenerator {
    
    public init(){}
    
    let _supportedTypes = [
        "CTFBARTActiveStep"
    ]
    
    public var supportedTypes: [String]! {
        return self._supportedTypes
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: BCLStepBuilderHelper) -> ORKStep? {
        
        guard let customStepDescriptor = helper.getCustomStepDescriptor(forJsonObject: jsonObject),
            let parameters = customStepDescriptor.parameters,
            let stepParamDescriptor = CTFBARTStepParamsDescriptor(json: parameters ) else {
                return nil
        }
        
        let stepParams = CTFBARTStepParams(numTrials: stepParamDescriptor.numTrials, earningsPerPump: stepParamDescriptor.earningsPerPump, maxPayingPumpsPerTrial: stepParamDescriptor.maxPayingPumpsPerTrial)
        
        let step = CTFBARTStep(identifier: customStepDescriptor.identifier)
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
