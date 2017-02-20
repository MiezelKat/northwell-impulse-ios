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
    
    var metadataAdditions: [String: AnyObject]? { get }
    var data: [String: AnyObject] { get }
    
    
    var startDate: Date? { get }
    var endDate: Date? { get }

}

extension SBBDataArchiveBuilder {
    
    public var metadataAdditions: [String: AnyObject]? {
        return nil
    }
    
    public var metadata: [String: AnyObject] {
    
        var metadata = [String: AnyObject]()
        
        if let startDate = self.startDate {
            metadata[self.kStartDate] = staticISO8601Formatter.string(from: startDate) as AnyObject?
        }
        
        if let endDate = self.endDate {
            metadata[self.kEndDate] = staticISO8601Formatter.string(from: endDate) as AnyObject?
        }
        
        if let metadataAdditions = self.metadataAdditions {
            metadataAdditions.forEach({
                metadata[$0] = $1
            })
        }
        
        return metadata
    }
    
    public func toArchive() -> SBBDataArchive? {
        
        let dataArchive = SBBDataArchive(reference: self.schemaIdentifier, jsonValidationMapping: nil)
        
        dataArchive.setArchiveInfoObject(self.schemaVersion, forKey: self.kSchemaRevisionKey)
        dataArchive.insertDictionary(intoArchive: self.data, filename: "data.json", createdOn: endDate ?? Date())
        dataArchive.insertDictionary(intoArchive: self.metadata, filename: "metadata.json", createdOn: endDate ?? Date())
        
        do {
            try dataArchive.complete()
            return dataArchive
        } catch let error {
            debugPrint("Failed to complete archive: \(error)")
            return nil
        }
        
    }
    
}
