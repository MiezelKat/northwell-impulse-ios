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

class CTFScaleFormResult: RSRPIntermediateResult {
    
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
        parameters: [String: ORKStepResult]
        ) -> RSRPIntermediateResult? {
    
        return nil
    }
}
