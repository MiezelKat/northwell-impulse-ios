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
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        let gender: String? = {
            guard let stepResult = parameters["gender"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let genderChoice = result.choiceAnswers?.first as? String else {
                    return nil
            }
            return genderChoice
        }()
        
        let age: Int? = {
            guard let stepResult = parameters["age"],
                let result = stepResult.firstResult as? ORKNumericQuestionResult,
                let age = result.numericAnswer?.intValue else {
                    return nil
            }
            return age
        }()
        
        let zipCode: String? = {
            guard let stepResult = parameters["zip_code"],
                let result = stepResult.firstResult as? ORKTextQuestionResult,
                let zipCode = result.textAnswer else {
                    return nil
            }
            return zipCode
        }()
        
        let education: String? = {
            guard let stepResult = parameters["education"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let eductionChoice = result.choiceAnswers?.first as? String else {
                    return nil
            }
            return eductionChoice
        }()
        
        let employment: [String]? = {
            guard let stepResult = parameters["employment_income"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let employmentChoices = result.choiceAnswers as? [String] else {
                    return nil
            }
            return employmentChoices
        }()
        
        let ethnicity: String? = {
            guard let stepResult = parameters["ethnicity"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let ethnicity = result.choiceAnswers?.first as? String else {
                    return nil
            }
            return ethnicity
        }()
        
        let race: String? = {
            guard let stepResult = parameters["race"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let race = result.choiceAnswers?.first as? String else {
                    return nil
            }
            return race
        }()
        
        let religion: [String]? = {
            guard let stepResult = parameters["religion"],
                let result = stepResult.firstResult as? ORKChoiceQuestionResult,
                let religion = result.choiceAnswers as? [String] else {
                    return nil
            }
            return religion
        }()
        
        let demographics = DemographicsResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            gender: gender,
            age: age,
            zipCode: zipCode,
            education: education,
            employment: employment,
            ethnicity: ethnicity,
            race: race,
            religion: religion
            )
        
        
        demographics.startDate = parameters["gender"]?.startDate
        demographics.endDate = parameters["religion"]?.endDate
        
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
    
    let ethnicity: String?
    let race: String?
    let religion: [String]?
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        gender: String?,
        age: Int?,
        zipCode: String?,
        education: String?,
        employment: [String]?,
        ethnicity: String?,
        race: String?,
        religion: [String]?) {
        
        self.gender = gender
        self.age = age
        self.zipCode = zipCode
        self.education = education
        self.employment = employment
        self.ethnicity = ethnicity
        self.race = race
        self.religion = religion
        
        super.init(
            type: DemographicsResult.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }

}
