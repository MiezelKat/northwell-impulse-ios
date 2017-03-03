//
//  SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import BridgeSDK

public protocol SBBDataArchiveBuilder: SBBDataArchiveConvertable {
    var schemaIdentifier: String { get }
    var schemaVersion: Int { get }
    var metadata: [String: Any] { get }
    var data: [String: Any] { get }
    var createdOn: Date { get }
    
    var kUUIDKey: String { get }
    var kTaskIdentifierKey: String { get }
    var kTaskRunUUIDKey: String { get }
    var kStartDate: String { get }
    var kEndDate: String { get }
    var kDataFilename: String { get }
    var kMetadataFilename: String { get }
}

extension SBBDataArchiveBuilder {
    
    public var kUUIDKey: String {
        return "UUID"
    }
    
    public var kTaskIdentifierKey: String {
        return "taskIdentifier"
    }
    
    public var kTaskRunUUIDKey: String {
        return "taskRunUUID"
    }
    
    public var kStartDate: String {
        return "startDate"
    }
    
    public var kEndDate: String {
        return "endDate"
    }
    
    public var kDataFilename: String {
        return "data.json"
    }
    
    public var kMetadataFilename: String {
        return "metadata.json"
    }
    
    public func toArchive() -> SBBDataArchive? {
        
        let dataArchive = SBBDataArchive(reference: self.schemaIdentifier, jsonValidationMapping: nil)
        
        guard JSONSerialization.isValidJSONObject(self.metadata),
            JSONSerialization.isValidJSONObject(self.data) else {
                assertionFailure("Cannot serialize json\n metadata: \(self.metadata)\n data: \(self.data)")
                return nil
        }
        
        dataArchive.setArchiveInfoObject(self.schemaVersion, forKey: self.kSchemaRevisionKey)
        dataArchive.insertDictionary(intoArchive: self.data, filename: self.kDataFilename, createdOn: self.createdOn)
        dataArchive.insertDictionary(intoArchive: self.metadata, filename: self.kMetadataFilename, createdOn: self.createdOn)
        
        do {
            try dataArchive.complete()
            return dataArchive
        } catch let error {
            debugPrint("Failed to complete archive: \(error)")
            return nil
        }
        
    }
    
}
