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

public enum CTFScheduledActivityType {
    
    case sequential // only supports first task
    case random //randomly selects a task to run
    
    init?(name: String?) {
        guard let type = name else { self = .sequential; return }
        switch(type) {
        case "sequential"      : self = .sequential
        case "random"       : self = .random
        default             : self = .sequential
        }
    }
}

open class CTFScheduledActivity: NSObject {
    private var activities: [CTFActivity]!
    private var _activity: CTFActivity?
    var guid: String!
    var title: String!
    var type: CTFScheduledActivityType!
    
    override init() {
        super.init()
    }
    
    init?(json: AnyObject) {
        super.init()
        
        guard let tasks = json["tasks"] as? [AnyObject],
            let title = json["scheduleTitle"] as? String,
            let scheduleIdentifier = json["scheduleIdentifier"] as? String,
            let type = CTFScheduledActivityType(name: json["activityType"] as? String) else {
                return nil
        }
        
        self.activities = tasks.flatMap { task in
            return CTFActivity(json: task)
        }
        
        self.title = title
        self.guid = scheduleIdentifier
        self.type = type
    }
    
    private func selectActivity() -> CTFActivity? {
        switch(self.type) {
        case .some(.sequential):
            return self.activities.first
            
        case .some(.random):
            return self.activities?.random()
        default:
            return nil
        }
    }
    
    var activity: CTFActivity! {
        
        if self._activity == nil {
            self._activity = self.selectActivity()
        }
        
        return self._activity
        
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
