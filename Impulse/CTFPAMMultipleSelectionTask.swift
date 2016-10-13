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

    let task: PAMMultipleSelectionTask
    init(dictionaryRepresentation: NSDictionary) {
        self.task = PAMMultipleSelectionTask(identifier: "testIdentifier", json: dictionaryRepresentation, bundle:  Bundle(for: PAMMultipleSelectionTask.self))
        super.init()
    }
    
    
    var taskIdentifier: String! {
        return "PAM"
    }
    
    var schemaIdentifier: String! {
        return "1"
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
