//
//  DemographicsResult+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 2/23/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation

extension DemographicsResult {
    //SBBDataArchiveConvertableFunctions
    static public let kSBBSchemaID = "demographics_v2"
    static public let kSBBSchemaVersion = 1
    
    override public var schemaIdentifier: String {
        return DemographicsResult.kSBBSchemaID
    }
    
    override public var schemaVersion: Int {
        return DemographicsResult.kSBBSchemaVersion
    }
    
    override public var data: [String: Any] {
        return [
            "gender": self.gender as Any,
            "age": self.age as Any,
            "zip_code": self.zipCode as Any,
            "education": self.education as Any,
            "ethnicity": self.ethnicity as Any,
            "race": self.race as Any
        ]
    }
}
