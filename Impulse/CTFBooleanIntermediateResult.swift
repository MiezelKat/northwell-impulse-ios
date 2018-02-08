//
//  CTFBooleanIntermediateResult.swift
//  Impulse
//
//  Created by James Kizer on 2/7/18.
//  Copyright © 2018 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor
import ResearchKit

class CTFBooleanIntermediateResult: RSRPIntermediateResult, RSRPFrontEndTransformer {
    
    static public let kType = "CTFBooleanResult"
    
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
        
        let resultMap:[String: AnyObject] = {
            var map: [String: AnyObject] = [:]
            stepResults.forEach { (stepResult) in
                if let boolResult = stepResult.results?.first as? ORKBooleanQuestionResult,
                    let boolValue = boolResult.booleanAnswer {
                    map[stepResult.identifier] = boolValue
                }
            }
            
            return map
        }()
        
        guard resultMap.count > 0 else {
            return nil
        }
        
        return CTFBooleanIntermediateResult(
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
    let resultMap: [String:AnyObject]
    
    public init(
        uuid: UUID,
        taskIdentifier: String,
        taskRunUUID: UUID,
        startDate: Date?,
        endDate: Date?,
        schemaID: String,
        schemaVersion: Int,
        resultMap: [String:AnyObject]) {
        
        self.schemaID = schemaID
        self.version = schemaVersion
        self.resultMap = resultMap
        
        super.init(
            type: CTFBooleanIntermediateResult.kType,
            uuid: uuid,
            taskIdentifier: taskIdentifier,
            taskRunUUID: taskRunUUID
        )
        
        self.startDate = startDate
        self.endDate = endDate
        
        
    }
    
}

extension CTFBooleanIntermediateResult {
    //SBBDataArchiveConvertableFunctions
    
    override public var schemaIdentifier: String {
        return self.schemaID
    }
    
    override public var schemaVersion: Int {
        return self.version
    }
    
    override public var data: [String: Any] {
        return self.resultMap
    }
}
