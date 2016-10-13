//
//  CTFActivity.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit

class CTFActivity: NSObject {
    var title: String!
    var identifier: String!
    
    override init() {
        super.init()
    }
     
    init?(json: AnyObject) {
        super.init()
        guard let title = json["taskTitle"] as? String,
            let taskIdentifier = json["taskIdentifier"] as? String
            else {
                return nil
        }
        
        self.title = title
        self.identifier = taskIdentifier
    }
}
