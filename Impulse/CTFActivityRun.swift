//
//  CTFActivityRun.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/12/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor


class CTFActivityRun: NSObject {
    
    let identifier: String
    let activity: JsonElement
    let resultTransforms: [RSRPResultTransform]?
    let onCompletionActions: [CTFActionDescriptor]?
    
    
    init(identifier: String,
         activity: JsonElement,
         resultTransforms: [RSRPResultTransform]?,
         onCompletionActions: [CTFActionDescriptor]?) {
        
        self.identifier = identifier
        self.activity = activity
        self.resultTransforms = resultTransforms
        self.onCompletionActions = onCompletionActions
    }

}
