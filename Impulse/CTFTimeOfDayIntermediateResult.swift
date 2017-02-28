//
//  CTFTimeOfDayIntermediateResult.swift
//  Impulse
//
//  Created by James Kizer on 2/27/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

class CTFTimeOfDayIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    static public let kType = "CTFTimeOfDayResult"
    
    private static let supportedTypes = [
        kType
    ]
    
    public static func supportsType(type: String) -> Bool {
        return supportedTypes.contains(type)
    }
    
    public static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    public static let calendar = Calendar(identifier: .gregorian)
    
    public static func transform(
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: AnyObject]
        ) -> RSRPIntermediateResult? {
        
        guard let schemaID = parameters["schemaID"] as? String,
            let schemaVersion = parameters["schemaVersion"] as? Int,
            let stepResult = parameters["result"] as? ORKStepResult,
            let keyString = parameters["key"] as? String,
            let timeOfDayResult = stepResult.results?.first as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer,
            let date = calendar.date(from: dateComponents) else {
                return nil
        }
        
        let timeOfDay = formatter.string(from: date)
        return CTFTimeOfDayIntermediateResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            startDate: stepResult.startDate,
            endDate: stepResult.endDate,
            schemaID: schemaID,
            schemaVersion: schemaVersion,
            timeOfDay: timeOfDay,
            key: keyString
        )
    }
    
    let schemaID: String
    let version: Int
    let timeOfDay: String
    let key: String
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        startDate: Date,
        endDate: Date,
        schemaID: String,
        schemaVersion: Int,
        timeOfDay: String,
        key: String) {
        
        self.schemaID = schemaID
        self.version = schemaVersion
        self.timeOfDay = timeOfDay
        self.key = key
        
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
