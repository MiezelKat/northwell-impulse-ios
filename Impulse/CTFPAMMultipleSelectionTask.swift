//
//  CTFPAMMultipleSelectionTask.swift
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK
import SDLRKX

@objc class CTFPAMMultipleSelectionTask: NSObject, SBABridgeTask, SBAStepTransformer {

    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var task: PAMMultipleSelectionTask!

    
    init(dictionaryRepresentation: NSDictionary) {
        super.init()
        
        if let dict = dictionaryRepresentation as? [String: AnyObject] {
            self._taskIdentifier = dict["taskIdentifier"] as! String
            self._schemaIdentifier = dict["schemaIdentifier"] as? String
            self.task = PAMMultipleSelectionTask(identifier: self._taskIdentifier, json: dictionaryRepresentation, bundle:  Bundle(for: PAMMultipleSelectionTask.self))
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
        return self.task.steps[0]
    }
    
}
