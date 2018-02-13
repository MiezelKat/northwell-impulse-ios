//
//  CTFBARTSummary+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 3/2/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation
import sdlrkx
import BridgeSDK

extension CTFBARTSummary {
    
    //its up to this convertable to manage the schema id and schema revision
    override public var schemaIdentifier: String {
        return "bart_v2"
    }
    
    override public var schemaVersion: Int {
        return 1
    }
    
    override public var data: [String: Any] {
        return self.dataDictionary()
    }
    
}
