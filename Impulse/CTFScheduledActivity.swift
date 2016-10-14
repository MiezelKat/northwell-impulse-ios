//
//  CTFScheduledActivity.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit

//schedule.activity
//schedule.isCompleted
//schedule.isCompleted
//schedule.isExpired
//schedule.isToday
//schedule.isTomorrow

//@property (nonatomic, strong) NSDate* expiresOn;
//
//@property (nonatomic, strong) NSDate* finishedOn;
//
//@property (nonatomic, strong) NSString* guid;
//
//@property (nonatomic, strong) NSNumber* persistent;
//
//@property (nonatomic, assign) BOOL persistentValue;
//
//@property (nonatomic, strong) NSDate* scheduledOn;
//
//@property (nonatomic, strong) NSDate* startedOn;
//
//@property (nonatomic, strong) NSString* status;
//
//@property (nonatomic, strong, readwrite) SBBActivity *activity;

open class CTFScheduledActivity: NSObject {
    var activity: CTFActivity!
    var guid: String!
    var title: String!
    
    override init() {
        super.init()
    }
    
    convenience init?(guid: String?, title: String?, activity: CTFActivity?) {
        self.init()
        
        self.guid = guid
        self.title = title
        self.activity = activity
    }
    
    
}

public extension CTFScheduledActivity {
    
//    public var isCompleted: Bool {
//        return self.finishedOn != nil
//    }
//    
//    public var isExpired: Bool {
//        return (self.expiresOn != nil) && (NSDate().earlierDate(self.expiresOn) == self.expiresOn)
//    }
//    
//    public var isNow: Bool {
//        return !isCompleted && ((self.scheduledOn == nil) || ((self.scheduledOn.timeIntervalSinceNow < 0) && !isExpired))
//    }
//    
//    var isToday: Bool {
//        return SBBScheduledActivity.availableTodayPredicate().evaluateWithObject(self)
//    }
//    
//    var isTomorrow: Bool {
//        return SBBScheduledActivity.scheduledTomorrowPredicate().evaluateWithObject(self)
//    }
//    
//    var scheduledTime: String {
//        if isCompleted {
//            return ""
//        }
//        else if isNow {
//            return Localization.localizedString("SBA_NOW")
//        }
//        else {
//            return NSDateFormatter.localizedStringFromDate(scheduledOn, dateStyle: .NoStyle, timeStyle: .ShortStyle)
//        }
//    }
//    
//    var expiresTime: String? {
//        if expiresOn == nil { return nil }
//        return NSDateFormatter.localizedStringFromDate(expiresOn, dateStyle: .NoStyle, timeStyle: .ShortStyle)
//    }
    
//    public dynamic var taskIdentifier: String? {
//        return (self.activity.task != nil) ? self.activity.task.identifier : nil
//    }
}
