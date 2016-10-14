//
//  CTFPulsusFormBridgeTask.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/19/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK

//class CTFPulsusFormStepTransformer: NSObject, SBAStepTransformer {
//    
//    //this needs to contain all the info necessary to render a step
//    //in the case of the CTFPulsusFormStep, this includes:
//    //  - identifier
//    //  - title
//    //  - ORKFormItems (or info to generate)
//    //  - 
//    
//    var stepIdentifier: String!
//    var stepTitle: String?
//    var formItems: [ORKFormItem]?
//    
//    init(identifier: String, title: String?, formItems: [ORKFormItem]?) {
//        super.init()
//        self.stepIdentifier = identifier
//        self.stepTitle = title
//        self.formItems = formItems
//    }
//    
//    func transformToStep(with factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep? {
//        let formStep = CTFPulsusFormStep(identifier: self.stepIdentifier)
//        formStep.title = self.stepTitle
//        formStep.isOptional = false
//        formStep.formItems = self.formItems
//        
//        return formStep
//    }
//}

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
//        print(range)
        let minimumValue: Int = range?["min"] as? Int ?? 0
        let maximumValue: Int = range?["max"] as? Int ?? 10
        let defaultValue: Int = range?["default"] as? Int ?? 5
        let stepValue: Int = range?["step"] as? Int ?? 1
        let maximumValueDescription: String = range?["maxValueText"] as? String ?? "extremely"
        let minimumValueDescription: String = range?["minValueText"] as? String ??  "not at all"

        let scaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: maximumValue, minimumValue: minimumValue, defaultValue: defaultValue, step: stepValue, vertical: false, maximumValueDescription: maximumValueDescription, minimumValueDescription: minimumValueDescription)
        
        return ORKFormItem(identifier: itemIdentifier, text: text, answerFormat: scaleAnswerFormat)
    }
    
    init(dictionaryRepresentation: NSDictionary) {
//        print(dictionaryRepresentation)
        super.init()
        
        self._taskIdentifier = dictionaryRepresentation["taskIdentifier"] as! String
        self._schemaIdentifier = dictionaryRepresentation["schemaIdentifier"] as? String
        
        
        guard let dictionaryItems = (dictionaryRepresentation["items"] as? [AnyObject]) else {
                return
        }
        
        self.formItems = dictionaryItems.flatMap(CTFPulsusFormBridgeTask.formItemFromDictionary)
        self.stepTitle = dictionaryRepresentation["title"] as? String
//        
//        self.stepTransformer = CTFPulsusFormStepTransformer(identifier: self._taskIdentifier,
//                                                            title: dictionaryRepresentation["title"] as? String,
//                                                            formItems: formItems)
        
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
