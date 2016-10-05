//
//  CTFActivityResult.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/27/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import Foundation
import ResearchKit

class CTFActivityResult: ORKTaskResult {

//    @property (nonatomic, readwrite) SBBScheduledActivity *schedule;
//    @property (nonatomic, readwrite, copy) NSNumber *schemaRevision;
//    @property (nonatomic, readwrite, copy) NSString *schemaIdentifier;
    
    var schedule: CTFScheduledActivity?
    var schemaRevision: NSNumber?
    var schemaIdentifier: String?
}
