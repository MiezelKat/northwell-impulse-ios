//
//  NSDictionary+SBAFormStepSurveyItem.swift
//  Impulse
//
//  Created by James Kizer on 10/7/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Foundation
import BridgeAppSDK

extension NSDictionary {
    var range: AnyObject? {
        print(self)
        guard let range = self["range"] else {
            return nil
        }
        
        return CTFNumberRange(with: range as AnyObject)
    }
    
    public var items: [Any]? {
        let items = self["items"] as? [Any]
        return items?.map { item in
            if let formStepSurveyItem = item as? SBAFormStepSurveyItem,
                CTFFormStepSurveyItem.isCTFFormStep(formStepSurveyItem: formStepSurveyItem) {
                return CTFFormStepSurveyItem(with: formStepSurveyItem)
            }
            else {
              return item
            }
        }
    }
    
//    func createAnswerFormat() -> ORKAnswerFormat? {
//        guard let subtype = self.surveyItemType.formSubtype() else { return nil }
//        switch(subtype) {
//        case .boolean:
//            return ORKBooleanAnswerFormat()
//        case .text:
//            return ORKTextAnswerFormat()
//        case .singleChoice, .multipleChoice:
//            guard let textChoices = self.items?.map({createTextChoice(from: $0)}) else { return nil }
//            let style: ORKChoiceAnswerStyle = (subtype == .singleChoice) ? .singleChoice : .multipleChoice
//            return ORKTextChoiceAnswerFormat(style: style, textChoices: textChoices)
//        case .date, .dateTime:
//            let style: ORKDateAnswerStyle = (subtype == .date) ? .date : .dateAndTime
//            let range = self.range as? SBADateRange
//            return ORKDateAnswerFormat(style: style, defaultDate: nil, minimumDate: range?.minDate as Date?, maximumDate: range?.maxDate as Date?, calendar: nil)
//        case .time:
//            return ORKTimeOfDayAnswerFormat()
//        case .duration:
//            return ORKTimeIntervalAnswerFormat()
//        case .integer, .decimal, .scale:
//            guard let range = self.range as? SBANumberRange else {
//                assertionFailure("\(subtype) requires a valid number range")
//                return nil
//            }
//            return range.createAnswerFormat(with: subtype)
//        case .timingRange:
//            guard let textChoices = self.items?.mapAndFilter({ (obj) -> ORKTextChoice? in
//                guard let item = obj as? SBANumberRange else { return nil }
//                return item.createORKTextChoice()
//            }) else { return nil }
//            let notSure = ORKTextChoice(text: Localization.localizedString("SBA_NOT_SURE_CHOICE"), value: "Not sure" as NSString)
//            return ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices + [notSure])
//            
//        default:
//            assertionFailure("Form item question type \(subtype) not implemented")
//            return nil
//        }
//    }
}

