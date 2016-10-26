//
//  CTFBARTBridgeTask.swift
//  Impulse
//
//  Created by James Kizer on 10/17/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import BridgeAppSDK

class CTFBARTBridgeTask: NSObject, SBABridgeTask, SBAStepTransformer {
    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var stepParams: CTFBARTStepParams!
    
    static func stepParamsFromDictionary(_ dictionary: AnyObject?) -> CTFBARTStepParams? {
        guard let paramsDict = dictionary,
            let numTrials = paramsDict["numberOfTrials"] as? Int,
            let earningsPerPump = paramsDict["earningsPerPump"] as? Float,
            let maxPayingPumpsPerTrial = paramsDict["maxPayingPumpsPerTrial"] as? Int else {
                return nil
        }
        
        return CTFBARTStepParams(
            numTrials: numTrials,
            earningsPerPump: earningsPerPump,
            maxPayingPumpsPerTrial: maxPayingPumpsPerTrial
        )
    }
    
    init(dictionaryRepresentation: NSDictionary) {
        //        print(dictionaryRepresentation)
        super.init()
        
        if let dict = dictionaryRepresentation as? [String: AnyObject] {
            self._taskIdentifier = dict["taskIdentifier"] as! String
            self._schemaIdentifier = dict["schemaIdentifier"] as? String
            self.stepParams = CTFBARTBridgeTask.stepParamsFromDictionary(dict["parameters"])
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let bartStep = CTFBARTStep(identifier: CTFBARTStep.identifier)
        bartStep.params = self.stepParams
        return bartStep
    }

}
