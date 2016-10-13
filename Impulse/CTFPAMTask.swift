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

    let task: PAMTask
    init(dictionaryRepresentation: NSDictionary) {
        self.task = PAMTask(identifier: "testIdentifier")
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
