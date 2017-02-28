//
//  CTFTimeOfDayIntermediateResult+SBBDataArchive.swift
//  Impulse
//
//  Created by James Kizer on 2/27/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation

extension CTFTimeOfDayIntermediateResult {
    //SBBDataArchiveConvertableFunctions
    
    override public var schemaIdentifier: String {
        return self.schemaID
    }
    
    override public var schemaVersion: Int {
        return self.version
    }
    
    override public var data: [String: Any] {
        return [
            self.key: self.timeOfDay
        ]
    }
}
