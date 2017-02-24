//
//  CTFExtendedMultipleChoiceStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/20/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import ResearchSuiteTaskBuilder
import Gloss
import ResearchKit

class CTFExtendedMultipleChoiceStepGenerator: RSTBMultipleChoiceStepGenerator {
    
    open override func generateChoices(items: [RSTBChoiceStepDescriptor.ChoiceItem], valueSuffix: String?, shouldShuffle: Bool?) -> [ORKTextChoice] {
        
        return super.generateChoices(items: items, valueSuffix: valueSuffix, shouldShuffle: false)
    }
    
    open override func generateFilter(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> ChoiceItemFilter? {
        
        guard let includedValuesKey: String = "filterItemsByValueInListKeyedBy" <~~ jsonObject,
            let stateHelper = helper.stateHelper,
            let includedValuesString = stateHelper.valueInState(forKey: includedValuesKey) as? String else {
            
            return super.generateFilter(type: type, jsonObject: jsonObject, helper: helper)
        }
        
        let includedValues = includedValuesString.components(separatedBy: ",")
        
        guard includedValues.count > 0 else {
            return super.generateFilter(type: type, jsonObject: jsonObject, helper: helper)
        }
        
        return { (item: RSTBChoiceStepDescriptor.ChoiceItem) in
            if let value = item.value as? String {
                return includedValues.contains(where: { (includedValue) -> Bool in
                    return includedValue.hasPrefix(value)
                })
            }
            else {
                return false
            }
        }
        
    }

}
