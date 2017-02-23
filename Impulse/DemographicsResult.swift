//
//  DemographicsResult.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/11/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

public class DemographicsResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    static public let kType = "Demographics"
    
    public static func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: ORKStepResult]
        ) -> RSRPIntermediateResult? {
        
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
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            gender: gender,
            age: age,
            zipCode: zipCode,
            education: education,
            employment: employment)
        
        demographics.startDate = parameters["GenderChoiceResult"]?.startDate ?? Date()
        demographics.endDate = parameters["EmploymentChoiceResult"]?.endDate ?? Date()
        
        return demographics
        
    }
    
    private static let supportedTypes = [
        DemographicsResult.kType
    ]
    
    public static func supportsType(type: String) -> Bool {
        return self.supportedTypes.contains(type)
    }
    
    
    //gender
    public let gender: String?
    //age
    public let age: Int?
    //zipcode
    public let zipCode: String?
    //education
    public let education: String?
    //employment
    public let employment: [String]?
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        gender: String?,
        age: Int?,
        zipCode: String?,
        education: String?,
        employment: [String]? ) {
        
        self.gender = gender
        self.age = age
        self.zipCode = zipCode
        self.education = education
        self.employment = employment
        
        super.init(
            type: DemographicsResult.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }

}
