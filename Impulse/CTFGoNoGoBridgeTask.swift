//
//  CTFGoNoGoBridgeTask.swift
//  Impulse
//
//  Created by James Kizer on 10/5/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import BridgeAppSDK



class CTFGoNoGoBridgeTask: NSObject, SBABridgeTask, SBAStepTransformer {
    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var stepParams: CTFGoNoGoStepParameters!
    
    static func stepParamsFromDictionary(_ dictionary: AnyObject?) -> CTFGoNoGoStepParameters? {
//        print(dictionary)
        guard let paramsDict = dictionary,
            let numTrials = paramsDict["numberOfTrials"] as? Int,
            let waitTime = paramsDict["waitTime"] as? TimeInterval,
            let crossTime = paramsDict["crossTime"] as? TimeInterval,
            let blankTime = paramsDict["blankTime"] as? TimeInterval,
            let cueTimes = paramsDict["cueTimes"] as? [TimeInterval],
            let fillTime = paramsDict["fillTime"] as? TimeInterval,
            let goCueProbability = paramsDict["goCueProbability"] as? Double,
            let goCueTargetProbability = paramsDict["goCueTargetProbability"] as? Double,
            let noGoCueTargetProbability = paramsDict["noGoCueTargetProbability"] as? Double else {
            return nil
        }
        
        return CTFGoNoGoStepParameters(
            waitTime: waitTime,
            crossTime: crossTime,
            blankTime: blankTime,
            cueTimeOptions: cueTimes,
            fillTime: fillTime,
            goCueTargetProb: goCueTargetProbability,
            noGoCueTargetProb: noGoCueTargetProbability,
            goCueProb: goCueProbability,
            numTrials: numTrials)
    }
    
    init(dictionaryRepresentation: NSDictionary) {
//        print(dictionaryRepresentation)
        super.init()
        
        if let dict = dictionaryRepresentation as? [String: AnyObject] {
            self._taskIdentifier = dict["taskIdentifier"] as! String
            self._schemaIdentifier = dict["schemaIdentifier"] as? String
            self.stepParams = CTFGoNoGoBridgeTask.stepParamsFromDictionary(dict["parameters"])
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
        let goNoGoStep = CTFGoNoGoStep(identifier: CTFGoNoGoTask.CTFGoNoGoStepIdentifier)
        goNoGoStep.goNoGoParams = self.stepParams
        return goNoGoStep
    }
    
    
    
}
