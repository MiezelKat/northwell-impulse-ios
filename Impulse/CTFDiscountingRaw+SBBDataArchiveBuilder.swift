//
//  CTFDiscountingRaw+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 6/27/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import sdlrkx
import BridgeSDK


extension CTFDiscountingRaw {
    
    //its up to this convertable to manage the schema id and schema revision
    
    override public var schemaIdentifier: String {
        return "discounting_raw"
    }
    
    override public var schemaVersion: Int {
        return 2
    }
    
    override public var data: [String: Any] {
        return [
            "variableLabel": self.variableLabel,
            "variableArray": self.variableArray,
            "constantArray": self.constantArray,
            "choiceArray": self.choiceArray,
            "times": self.times
        ]
    }
    
}


