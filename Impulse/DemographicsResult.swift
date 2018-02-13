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
import ResearchSuiteExtensions

public class DemographicsResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    static public let kType = "Demographics"
    
    public static func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        let gender: String? = {
            guard let stepResult = parameters["gender"],
                let result = stepResult.firstResult as? RSEnhancedMultipleChoiceResult,
                let selection = result.choiceAnswers?.first,
                let genderChoice = selection.value as? String else {
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
                let result = stepResult.firstResult as? RSEnhancedMultipleChoiceResult,
                let selection = result.choiceAnswers?.first,
                let eductionChoice = selection.value as? String else {
                    return nil
            }
            return eductionChoice
        }()
        
        let ethnicity: String? = {
            guard let stepResult = parameters["ethnicity"],
                let result = stepResult.firstResult as? RSEnhancedMultipleChoiceResult,
                let selection = result.choiceAnswers?.first,
                let ethnicity = selection.value as? String else {
                    return nil
            }
            return ethnicity
        }()
        
        let race: String? = {
            guard let stepResult = parameters["race"],
                let result = stepResult.firstResult as? RSEnhancedMultipleChoiceResult,
                let selection = result.choiceAnswers?.first,
                let race = selection.value as? String else {
                    return nil
            }
            return race
        }()
        
        let demographics = DemographicsResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            gender: gender,
            age: age,
            zipCode: zipCode,
            education: education,
            ethnicity: ethnicity,
            race: race
            )
        
        
        demographics.startDate = parameters["gender"]?.startDate
        demographics.endDate = parameters["race"]?.endDate
        
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
    
    let ethnicity: String?
    let race: String?
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        gender: String?,
        age: Int?,
        zipCode: String?,
        education: String?,
        ethnicity: String?,
        race: String?) {
        
        self.gender = gender
        self.age = age
        self.zipCode = zipCode
        self.education = education
        self.ethnicity = ethnicity
        self.race = race
        
        super.init(
            type: DemographicsResult.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }

}
