//
//  CTFScaleFormResult+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 2/26/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation

extension CTFScaleFormResult {
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
