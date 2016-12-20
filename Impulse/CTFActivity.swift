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
    var fileName: String!
    var className: String!
    var taskCompletionTimeString: String!
    
    override init() {
        super.init()
    }
     
    init?(json: AnyObject) {
        super.init()
        guard let title = json["taskTitle"] as? String,
            let taskIdentifier = json["taskID"] as? String,
        let taskFileName = json["taskFileName"] as? String,
        let taskClassName = json["taskClassName"] as? String,
        let taskCompletionTimeString = json["taskCompletionTimeString"] as? String
            else {
                return nil
        }
        
        self.title = title
        self.identifier = taskIdentifier
        self.fileName = taskFileName
        self.className = taskClassName
        self.taskCompletionTimeString = taskCompletionTimeString
    }
}
