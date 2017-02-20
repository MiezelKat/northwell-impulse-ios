//
//  CTFDelayDiscountingRaw+SBBDataArchiveConvertable.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import sdlrkx
import BridgeSDK


extension CTFDelayDiscountingRaw: SBBDataArchiveBuilder {

    //its up to this convertable to manage the schema id and schema revision
    
    public var schemaIdentifier: String {
        return "delay_discounting_raw"
    }
    
    public var schemaVersion: Int {
        return 2
    }
    
    public var data: [String: AnyObject] {
        return [
            "variableLabel": self.variableLabel as AnyObject,
            "nowArray": self.nowArray as AnyObject
        ]
    }

}
