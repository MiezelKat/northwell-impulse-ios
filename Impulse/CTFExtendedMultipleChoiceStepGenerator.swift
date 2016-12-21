//
//  CTFExtendedMultipleChoiceStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/20/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Bricoleur
import Gloss
import ResearchKit

class CTFExtendedMultipleChoiceStepGenerator: BCLMultipleChoiceStepGenerator {
    
    open override func generateChoices(items: [BCLChoiceStepDescriptor.ChoiceItem], valueSuffix: String?, shouldShuffle: Bool?) -> [ORKTextChoice] {
        
        return super.generateChoices(items: items, valueSuffix: valueSuffix, shouldShuffle: false)
    }
    
    open override func generateFilter(type: String, jsonObject: JSON, helper: BCLStepBuilderHelper) -> ChoiceItemFilter? {
        
        guard let includedValuesKey: String = "filterItemsByValueInListKeyedBy" <~~ jsonObject,
            let stateHelper = helper.stateHelper,
            let includedValuesString = stateHelper.valueInState(forKey: includedValuesKey) as? String else {
            
            return super.generateFilter(type: type, jsonObject: jsonObject, helper: helper)
        }
        
        let includedValues = includedValuesString.components(separatedBy: ",")
        
        return { (item: BCLChoiceStepDescriptor.ChoiceItem) in
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
