//
//  DemographicsResultTransformer.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/11/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteResultsProcessor

class DemographicsResultTransformer: RSRPFrontEndTransformer {
    
    private static let supportedTypes = [
        "Demographics"
    ]
    
    public static func supportsType(type: String) -> Bool {
        return self.supportedTypes.contains(type)
    }

    
    public static func transform(parameters: [String : ORKStepResult]) -> RSRPIntermediateResult? {
        
        let gender: String? = {
            guard let stepResult = parameters["GenderChoiceResult"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let genderChoice = result.choiceAnswers?.first as? String else {
                    return nil
            }
            return genderChoice
        }()
        
        let age: Int? = {
            guard let stepResult = parameters["AgeIntegerResult"],
                let result = stepResult.firstResult as? ORKNumericQuestionResult,
                let age = result.numericAnswer?.intValue else {
                    return nil
            }
            return age
        }()
        
        let zipCode: String? = {
            guard let stepResult = parameters["ZipTextResult"],
                let result = stepResult.firstResult as? ORKTextQuestionResult,
                let zipCode = result.textAnswer else {
                    return nil
            }
            return zipCode
        }()
        
        let education: String? = {
            guard let stepResult = parameters["EducationChoiceResult"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let eductionChoice = result.choiceAnswers?.first as? String else {
                    return nil
            }
            return eductionChoice
        }()
        
        let employment: [String]? = {
            guard let stepResult = parameters["EmploymentChoiceResult"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let employmentChoices = result.choiceAnswers as? [String] else {
                    return nil
            }
            return employmentChoices
        }()
        
        let demographics = DemographicsResult(
            gender: gender,
            age: age,
            zipCode: zipCode,
            education: education,
            employment: employment)
        
        demographics.startDate = parameters["GenderChoiceResult"]?.startDate ?? Date()
        demographics.endDate = parameters["EmploymentChoiceResult"]?.endDate ?? Date()
        
        return demographics
        
    }
    
    


}
