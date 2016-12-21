//
//  PAMStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import Bricoleur
import ResearchKit
import SDLRKX
import Gloss

class PAMStepGenerator: BCLBaseStepGenerator {
    
    public init(){}
    
    let _supportedTypes = [
        "PAM"
    ]
    
    public var supportedTypes: [String]! {
        return self._supportedTypes
    }
    
    open func generateStep(type: String, jsonObject: JSON, helper: BCLStepBuilderHelper) -> ORKStep? {
        
        guard let customStepDescriptor = helper.getCustomStepDescriptor(forJsonObject: jsonObject) else {
                return nil
        }
        
        return PAMStep.create(identifier: customStepDescriptor.identifier)
    }
    
    open func processStepResult(type: String,
                                jsonObject: JsonObject,
                                result: ORKStepResult,
                                helper: BCLStepBuilderHelper) -> JSON? {
        return nil
    }
    
}
