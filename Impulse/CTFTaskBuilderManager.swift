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
import ResearchSuiteExtensions

class CTFTaskBuilderManager: NSObject {
    
    static let randomMultipleChoice = false
    
    static let stepGeneratorServices: [RSTBStepGenerator] = [
        RSTBInstructionStepGenerator(),
        RSTBTextFieldStepGenerator(),
        RSTBIntegerStepGenerator(),
        RSEnhancedSingleChoiceStepGenerator(),
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
        RSEnhancedMultipleChoiceStepGenerator(),
        RSTBVisualConsentStepGenerator(),
        RSTBConsentReviewStepGenerator()
    ]
    
   static let answerFormatGeneratorServices: [RSTBAnswerFormatGenerator] = [
        RSTBTextFieldStepGenerator(),
        RSTBIntegerStepGenerator(),
        RSTBTimePickerStepGenerator(),
        RSTBDatePickerStepGenerator()
    ]
    
    static let elementGeneratorServices: [RSTBElementGenerator] = [
        RSTBElementListGenerator(),
        RSTBElementFileGenerator(),
        RSTBElementSelectorGenerator()
    ]
    
    open class var consentDocumentGeneratorServices: [RSTBConsentDocumentGenerator.Type] {
        return [
            RSTBStandardConsentDocument.self
        ]
    }
    
    open class var consentSectionGeneratorServices: [RSTBConsentSectionGenerator.Type] {
        return [
            RSTBStandardConsentSectionGenerator.self
        ]
    }
    
    open class var consentSignatureGeneratorServices: [RSTBConsentSignatureGenerator.Type] {
        return [
            RSTBParticipantConsentSignatureGenerator.self,
            RSTBInvestigatorConsentSignatureGenerator.self
        ]
    }

    let rstb: RSTBTaskBuilder

    init(stateHelper: RSTBStateHelper) {
        
        // Do any additional setup after loading the view, typically from a nib.
        self.rstb = RSTBTaskBuilder(
            stateHelper: stateHelper,
            elementGeneratorServices: CTFTaskBuilderManager.elementGeneratorServices,
            stepGeneratorServices: CTFTaskBuilderManager.stepGeneratorServices,
            answerFormatGeneratorServices: CTFTaskBuilderManager.answerFormatGeneratorServices,
            consentDocumentGeneratorServices: CTFTaskBuilderManager.consentDocumentGeneratorServices,
            consentSectionGeneratorServices: CTFTaskBuilderManager.consentSectionGeneratorServices,
            consentSignatureGeneratorServices: CTFTaskBuilderManager.consentSignatureGeneratorServices
        )
        
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
