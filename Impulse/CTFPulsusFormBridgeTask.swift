//
//  CTFPulsusFormBridgeTask.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/19/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK

class CTFPulsusFormBridgeTask: NSObject, SBABridgeTask, SBAStepTransformer {
    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var stepTransformer: SBAStepTransformer?
    
    var formItems: [ORKFormItem]?
    var stepTitle: String?
    
    static func formItemFromDictionary(_ dictionary: AnyObject?) -> ORKFormItem? {
        
        let itemIdentifier:String = (dictionary?["identifier"])! as! String
        let text: String? = dictionary?["text"] as? String
        
        let range: [String: AnyObject]? = dictionary?["range"] as? [String: AnyObject]
        let minimumValue: Int = range?["min"] as? Int ?? 0
        let maximumValue: Int = range?["max"] as? Int ?? 10
        let defaultValue: Int = range?["default"] as? Int ?? 5
        let stepValue: Int = range?["step"] as? Int ?? 1
        let maximumValueDescription: String? = range?["maxValueText"] as? String
        let intermediateValueDescription: String? = range?["midValueText"] as? String
        let minimumValueDescription: String? = range?["minValueText"] as? String
        
        let scaleAnswerType: CTFScaleAnswerType? = {
            switch(dictionary?["type"] as? String){
            case .some("likert"):
                return CTFScaleAnswerType.likert
            case .some("semanticDifferential"):
                return CTFScaleAnswerType.semanticDifferential
            default:
                return nil
            }
        }()
        

//        let scaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: maximumValue, minimumValue: minimumValue, defaultValue: defaultValue, step: stepValue, vertical: false, maximumValueDescription: maximumValueDescription, minimumValueDescription: minimumValueDescription)
        let scaleAnswerFormat = CTFScaleAnswerFormat(withMaximumValue: maximumValue,
                                                     minimumValue: minimumValue,
                                                     defaultValue: defaultValue,
                                                     step: stepValue,
                                                     vertical: false,
                                                     maximumValueDescription: maximumValueDescription,
                                                     intermediateValueDescription: intermediateValueDescription,
                                                     minimumValueDescription: minimumValueDescription,
                                                     scaleAnswerType: scaleAnswerType)
        
        return ORKFormItem(identifier: itemIdentifier, text: text, answerFormat: scaleAnswerFormat)
    }
    
    init(dictionaryRepresentation: NSDictionary) {
        super.init()
        
        self._taskIdentifier = dictionaryRepresentation["taskIdentifier"] as! String
        self._schemaIdentifier = dictionaryRepresentation["schemaIdentifier"] as? String
        
        
        guard let dictionaryItems = (dictionaryRepresentation["items"] as? [AnyObject]) else {
                return
        }
        
        self.formItems = dictionaryItems.flatMap(CTFPulsusFormBridgeTask.formItemFromDictionary)
        self.stepTitle = dictionaryRepresentation["title"] as? String
        
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
        let formStep = CTFPulsusFormStep(identifier: self.taskIdentifier)
        formStep.title = self.stepTitle
        formStep.isOptional = false
        formStep.formItems = self.formItems
        
        return formStep
    }
    
    
    
}
