//
//  CTFScaleFormResult.swift
//  Impulse
//
//  Created by James Kizer on 2/25/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

class CTFScaleFormResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    static public let kType = "CTFScaleFormResult"
    
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
        
        let childResults = stepResults.flatMap({ (stepResult) -> [ORKScaleQuestionResult]? in
            return stepResult.results as? [ORKScaleQuestionResult]
        }).joined()
        
        guard childResults.count > 0 else {
            return nil
        }
        
        let identifierSuffix = parameters["identifierSuffix"] as? String
        
        let resultMap:[String: Int] = {
            var map: [String: Int] = [:]
            childResults.forEach { (result) in
                let identifier = result.identifier + (identifierSuffix ?? "")
                if let scaleAnswer = result.scaleAnswer {
                    map[identifier] = scaleAnswer.intValue
                }
            }
            
            return map
        }()

        return CTFScaleFormResult(
            uuid: UUID(),
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID,
            schemaID: schemaID,
            schemaVersion: schemaVersion,
            resultMap: resultMap
        )
    }

    let schemaID: String
    let version: Int
    let resultMap:[String: Int]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        schemaID: String,
        schemaVersion: Int,
        resultMap: [String: Int]) {
        
        self.schemaID = schemaID
        self.version = schemaVersion
        self.resultMap = resultMap
        
        super.init(
            type: DemographicsResult.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
    }
}
