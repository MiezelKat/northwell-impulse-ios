//
//  CTFFormStepSurveyItem.swift
//  Impulse
//
//  Created by James Kizer on 10/7/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit
import BridgeAppSDK


//public protocol SBAStepTransformer: class {
//    func transformToStep(with factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep?
//}
//
//public protocol SBASurveyItem: SBAStepTransformer {
//    var identifier: String! { get }
//    var surveyItemType: SBASurveyItemType { get }
//    var stepTitle: String? { get }
//    var stepText: String? { get }
//    var options: [String : AnyObject]? { get }
//}
//
//public protocol SBAFormStepSurveyItem: SBASurveyItem {
//    var questionStyle: Bool { get }
//    var placeholderText: String? { get }
//    var optional: Bool { get }
//    var items: [Any]? { get }
//    var range: AnyObject? { get }
//    var skipIdentifier: String? { get }
//    var skipIfPassed: Bool { get }
//    var rulePredicate: NSPredicate? { get }
//}



class CTFFormStepSurveyItem: NSObject, SBAFormStepSurveyItem {
    
    var dict: SBAFormStepSurveyItem!
    
    static func isCTFFormStep(formStepSurveyItem: SBAFormStepSurveyItem) -> Bool {
        if let customTypeIdentifier = formStepSurveyItem.surveyItemType.customTypeIdentifier {
            print(customTypeIdentifier)
            return true
        }
        
        return false
    }
    
    init(with dictionary: SBAFormStepSurveyItem) {
        super.init()
        self.dict = dictionary
    }
    
    func createFormItem(text: String?) -> ORKFormItem {
        
        return ORKFormItem()
    }
    
    func createAnswerFormat() -> ORKAnswerFormat? {
        return nil
    }
    
    func transformToStep(with factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep? {
        return nil
    }
    
    var identifier: String! {
        return self.dict.identifier
    }
    
    var surveyItemType: SBASurveyItemType {
        return self.dict.surveyItemType
    }
    
    var stepTitle: String?{
        return self.dict.stepTitle
    }
    
    var stepText: String? {
        return self.dict.stepText
    }
    
    var options: [String : AnyObject]? {
        return self.dict.options
    }
    
    var questionStyle: Bool {
        return self.dict.questionStyle
    }
    
    var placeholderText: String? {
        return self.dict.placeholderText
    }
    
    var optional: Bool {
        return self.dict.optional
    }
    
    var items: [Any]? {
        return self.dict.items
    }
    
    var range: AnyObject? {
        return self.dict.range
    }
    
    var skipIdentifier: String? {
        return self.dict.skipIdentifier
    }
    
    var skipIfPassed: Bool {
        return self.dict.skipIfPassed
    }
    
    var rulePredicate: NSPredicate? {
        return self.dict.rulePredicate
    }
    
}

extension SBAFormStepSurveyItem {

    func buildFormItems(with step: SBAFormProtocol, isSubtaskStep: Bool) {
//        if case SBASurveyItemType.form(.compound) = self.surveyItemType {
//            step.formItems = self.items?.map({
//                let formItem = $0 as! SBAFormStepSurveyItem
//                return formItem.createFormItem(text: formItem.stepText)
//            })
//        }
//        else {
//            step.formItems = [self.createFormItem(text: nil)]
//        }
    }
}
