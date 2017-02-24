 //
//  RSRPIntermediateResult+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 2/22/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation
import ResearchSuiteResultsProcessor
import BridgeSDK

extension RSRPIntermediateResult: SBBDataArchiveBuilder {

    public var schemaIdentifier: String {
        fatalError("not implemented")
    }
    
    public var schemaVersion: Int {
        fatalError("not implemented")
    }
    
    public var data: [String: Any] {
        fatalError("not implemented")
    }
    
    public var createdOn: Date {
        return self.endDate ?? (self.startDate ?? Date())
    }
    
    public var metadata: [String: Any] {
        
        var metadata = [String: Any]()
        
        metadata[self.kUUIDKey] = self.uuid.uuidString
        metadata[self.kTaskIdentifierKey] = self.taskIdentifier
        metadata[self.kTaskRunUUIDKey] = self.taskRunUUID.uuidString
        
        if let startDate = self.startDate {
            metadata[self.kStartDate] = staticISO8601Formatter.string(from: startDate)
        }
        
        if let endDate = self.endDate {
            metadata[self.kEndDate] = staticISO8601Formatter.string(from: endDate)
        }
        
        if let metadataAdditions = self.userInfo {
            metadataAdditions.forEach({
                metadata[$0] = $1
            })
        }
        
        return metadata
    }
    
}
