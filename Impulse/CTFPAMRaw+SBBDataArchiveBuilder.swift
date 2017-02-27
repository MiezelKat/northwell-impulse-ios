//
//  CTFPAMRaw+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 2/26/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation
import sdlrkx
import BridgeSDK


extension CTFPAMRaw {
    
    //its up to this convertable to manage the schema id and schema revision
    
    override public var schemaIdentifier: String {
        return "pam"
    }
    
    override public var schemaVersion: Int {
        return 2
    }
    
    override public var data: [String: Any] {
        return self.pamChoice
    }
    
}
