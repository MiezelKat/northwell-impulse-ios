//
//  CTFPAMTask.swift
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK
import SDLRKX

@objc class CTFPAMTask: NSObject, SBABridgeTask, SBAStepTransformer {

    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    
    init(dictionaryRepresentation: NSDictionary) {
        super.init()
        
        if let dict = dictionaryRepresentation as? [String: AnyObject] {
            self._taskIdentifier = dict["taskIdentifier"] as! String
            self._schemaIdentifier = dict["schemaIdentifier"] as? String
        }
    }
    
    
    var taskIdentifier: String! {
        return self._taskIdentifier
    }
    
    var schemaIdentifier: String! {
        return self._schemaIdentifier
    }
    
    var taskSteps: [SBAStepTransformer] {
        return [self]
    }
    
    var insertSteps: [SBAStepTransformer]? {
        return nil
    }

    func transformToStep(with factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep? {
        let task = PAMTask(identifier: self.taskIdentifier)
        return task.steps[0]
    }
    
}
