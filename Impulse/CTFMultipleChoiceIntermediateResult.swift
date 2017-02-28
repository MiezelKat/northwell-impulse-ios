//
//  CTFMultipleChoiceIntermediateResult.swift
//  Impulse
//
//  Created by James Kizer on 2/27/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

open class CTFMultipleChoiceIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    
    static public let kType = "CTFMultipleChoiceResult"
    
    private static let supportedTypes = [
        kType
    ]
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes.contains(type)
    }
    
    
    public static func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        guard let schemaID = parameters["schemaID"] as? String,
            let schemaVersion = parameters["schemaVersion"] as? Int,
            let stepResult = parameters["result"] as? ORKStepResult,
            let choiceResult = stepResult.results?.first as? ORKChoiceQuestionResult,
            let choices = choiceResult.choiceAnswers else {
                return nil
        }
        
        return CTFMultipleChoiceIntermediateResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            startDate: stepResult.startDate,
            endDate: stepResult.endDate,
            schemaID: schemaID,
            schemaVersion: schemaVersion,
            choices: choices
        )
    }
    
    let schemaID: String
    let version: Int
    let choices:[Any]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        startDate: Date,
        endDate: Date,
        schemaID: String,
        schemaVersion: Int,
        choices: [Any]) {
        
        self.schemaID = schemaID
        self.version = schemaVersion
        self.choices = choices
        
        super.init(
            type: CTFMultipleChoiceIntermediateResult.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
        
        self.startDate = startDate
        self.endDate = endDate
        
        
    }
    
    

}
