//
//  CTFDelayDiscountingRaw+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import sdlrkx
import BridgeSDK


extension CTFDelayDiscountingRaw {

    //its up to this convertable to manage the schema id and schema revision
    
    override public var schemaIdentifier: String {
        return "delay_discounting_raw_v2"
    }
    
    override public var schemaVersion: Int {
        return 1
    }
    
    override public var data: [String: Any] {
        return [
            "variableLabel": self.variableLabel,
            "nowArray": self.nowArray,
            "laterArray": self.laterArray,
            "choiceArray": self.choiceArray,
            "times": self.times
        ]
    }

}
