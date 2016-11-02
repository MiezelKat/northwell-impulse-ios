//
//  CTFDelayDiscountingBridgeTask.swift
//  Impulse
//
//  Created by Francesco Perera on 11/2/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import BridgeAppSDK

class CTFDelayDiscountingBridgeTask: NSObject ,SBABridgeTask,SBAStepTransformer{
    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var stepParams: CTFDelayDiscountingStepParams!
    
    static func stepParamsFromDictionary(_ dictionary: AnyObject?) -> CTFDelayDiscountingStepParams? {
        guard let paramsDict = dictionary,
            let maxAmount = paramsDict["maxAmount"] as? Double,
            let numQuestions = paramsDict["numQuestions"] as? Int,
            let nowDescription = paramsDict["nowDescription"] as? String,
            let laterDescription = paramsDict["laterDescription"] as? String,
            let formatString = paramsDict["formatString"] as? String else {
                return nil
        }
        
        return CTFDelayDiscountingStepParams(
            maxAmount:maxAmount,
            numQuestions: numQuestions,
            nowDescription:nowDescription,
            laterDescription:laterDescription,
            formatString:formatString
        )
    }
    
    init(dictionaryRepresentation: NSDictionary) {
        //        print(dictionaryRepresentation)
        super.init()
        
        if let dict = dictionaryRepresentation as? [String: AnyObject] {
            self._taskIdentifier = dict["taskIdentifier"] as! String
            self._schemaIdentifier = dict["schemaIdentifier"] as? String
            self.stepParams = CTFDelayDiscountingBridgeTask.stepParamsFromDictionary(dict["parameters"])
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
        let delayDiscountingStep = CTFDelayDiscountingStep(identifier: CTFDelayDiscountingStep.identifier)
        delayDiscountingStep.params = self.stepParams
        return delayDiscountingStep
    }
    

}
