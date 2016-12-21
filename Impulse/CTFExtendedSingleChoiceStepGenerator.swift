//
//  CTFNoShuffleSingleChoiceStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 12/20/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Bricoleur
import Gloss
import ResearchKit

class CTFExtendedSingleChoiceStepGenerator: BCLSingleChoiceStepGenerator {
    
    open override func generateChoices(items: [BCLChoiceStepDescriptor.ChoiceItem], valueSuffix: String?, shouldShuffle: Bool?) -> [ORKTextChoice] {
        
        return super.generateChoices(items: items, valueSuffix: valueSuffix, shouldShuffle: false)
    }

}
