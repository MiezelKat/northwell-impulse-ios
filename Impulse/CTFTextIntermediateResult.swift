//
//  CTFTextIntermediateResult.swift
//  Impulse
//
//  Created by James Kizer on 2/27/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

class CTFTextIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    static public let kType = "CTFTextResult"
    
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
            let schemaVersion = parameters["schemaVersion"] as? Int else {
                return nil
        }
        
        let stepResults: [ORKStepResult] = parameters.flatMap { (pair) -> ORKStepResult? in
            return pair.value as? ORKStepResult
        }
        
        let resultMap:[String: String] = {
            var map: [String: String] = [:]
            stepResults.forEach { (stepResult) in
                if let textResult = stepResult.results?.first as? ORKTextQuestionResult,
                    let text = textResult.textAnswer {
                    map[stepResult.identifier] = text
                }
            }
            
            return map
        }()
    
        guard resultMap.count > 0 else {
            return nil
        }

        return CTFTextIntermediateResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            startDate: stepResults.first?.startDate,
            endDate: stepResults.last?.endDate,
            schemaID: schemaID,
            schemaVersion: schemaVersion,
            resultMap: resultMap
        )
    }
    
    let schemaID: String
    let version: Int
    let resultMap: [String:String]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        startDate: Date?,
        endDate: Date?,
        schemaID: String,
        schemaVersion: Int,
        resultMap: [String:String]) {
        
        self.schemaID = schemaID
        self.version = schemaVersion
        self.resultMap = resultMap
        
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
