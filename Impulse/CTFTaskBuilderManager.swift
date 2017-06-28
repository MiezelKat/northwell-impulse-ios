//
//  CTFTaskBuilderManager.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 1/29/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import sdlrkx

class CTFTaskBuilderManager: NSObject {
    
    static let randomMultipleChoice = false
    
    static let stepGeneratorServices: [RSTBStepGenerator] = [
        RSTBInstructionStepGenerator(),
        RSTBTextFieldStepGenerator(),
        RSTBIntegerStepGenerator(),
        CTFExtendedSingleChoiceStepGenerator(),
        RSTBTimePickerStepGenerator(),
        RSTBFormStepGenerator(),
        CTFLikertFormStepGenerator(),
        CTFSemanticDifferentialFormStepGenerator(),
        PAMMultipleStepGenerator(),
        PAMStepGenerator(),
        CTFGoNoGoStepGenerator(),
        CTFBARTStepGenerator(),
        CTFDelayDiscountingStepGenerator(),
        CTFDiscountingStepGenerator(),
        RSTBDatePickerStepGenerator(),
        CTFExtendedMultipleChoiceStepGenerator()
    ]
    
   static let answerFormatGeneratorServices: [RSTBAnswerFormatGenerator] = [
        RSTBTextFieldStepGenerator(),
        RSTBIntegerStepGenerator(),
        RSTBTimePickerStepGenerator(),
        CTFExtendedSingleChoiceStepGenerator(),
        CTFExtendedMultipleChoiceStepGenerator(),
        RSTBDatePickerStepGenerator()
    ]
    
    static let elementGeneratorServices: [RSTBElementGenerator] = [
        RSTBElementListGenerator(),
        RSTBElementFileGenerator(),
        RSTBElementSelectorGenerator()
    ]

    let rstb: RSTBTaskBuilder

    init(stateHelper: RSTBStateHelper) {
        
        // Do any additional setup after loading the view, typically from a nib.
        self.rstb = RSTBTaskBuilder(
            stateHelper: stateHelper,
            elementGeneratorServices: CTFTaskBuilderManager.elementGeneratorServices,
            stepGeneratorServices: CTFTaskBuilderManager.stepGeneratorServices,
            answerFormatGeneratorServices: CTFTaskBuilderManager.answerFormatGeneratorServices)
        
        super.init()
        
        
    }
    
    static func getJson(forFilename filename: String, inBundle bundle: Bundle = Bundle.main) -> JsonElement? {
        
        guard let filePath = bundle.path(forResource: filename, ofType: "json")
            else {
                assertionFailure("unable to locate file \(filename)")
                return nil
        }
        
        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            else {
                assertionFailure("Unable to create NSData with content of file \(filePath)")
                return nil
        }
        
        let json = try! JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        return json as JsonElement?
    }
    

}
