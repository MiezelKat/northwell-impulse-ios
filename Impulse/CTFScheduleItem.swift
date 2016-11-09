//
//  CTFScheduleItem.swift
//  Impulse
//
//  Created by James Kizer on 10/14/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit

public enum CTFScheduleItemType {
    
    case sequential // only supports first task
    case random //randomly selects a task to run
    case selectOneByDate
    
    init?(name: String?) {
        guard let type = name else { self = .sequential; return }
        switch(type) {
        case "sequential"      : self = .sequential
        case "random"       : self = .random
        case "selectOneByDate" : self = .selectOneByDate
        default             : self = .sequential
        }
    }
}

let kSelectionUUID: String = "selectionUUID"

class CTFScheduleItem: NSObject {
    
//    private var activities: [CTFActivity]!
    var identifier: String!
    var guid: String!
    var title: String!
    var type: CTFScheduleItemType!
    var trial: Bool! = false
    var timeEstimate: String!
    var taskList: [AnyObject]!
    
    override init() {
        super.init()
    }
    
    init?(json: AnyObject) {
        super.init()
        
        print(json)
        
        guard let tasks = json["tasks"] as? [AnyObject],
            let title = json["scheduleTitle"] as? String,
            let scheduleIdentifier = json["scheduleIdentifier"] as? String,
            let scheduleGUID = json["scheduleGUID"] as? String,
            let type = CTFScheduleItemType(name: json["activityType"] as? String),
            let trial = json["trialActivity"] as? Bool,
            let timeEstimate = json["timeEstimate"] as? String else {
                return nil
        }
        
        self.taskList = tasks
        
        self.title = title
        self.identifier = scheduleIdentifier
        self.guid = scheduleGUID
        self.type = type
        self.trial = trial
        self.timeEstimate = timeEstimate
    }
    
    func recursivelySelectByHash(hash: Int, tasks: [AnyObject]) -> CTFActivity? {
        //randomly select one
        if tasks.count > 0 {
            let index = abs(hash) % tasks.count
            let selectedObject = tasks[index]
            if let tasks = selectedObject["tasks"] as? [AnyObject] {
                return self.recursivelySelectByHash(hash: hash, tasks: tasks)
            }
            else {
                return CTFActivity(json: selectedObject)
            }
        }
        else {
            return nil
        }
    }
    
    static var myUUID: String {
        if let uuid = CTFKeychainHelpers.getKeychainObject(kSelectionUUID) as? String {
            return uuid
        }
        else {
            let uuid: String = UUID().uuidString
            CTFKeychainHelpers.setKeychainObject(uuid as NSString, forKey: kSelectionUUID)
            return uuid
        }
    }
    
    private func selectActivity() -> CTFActivity? {
        switch(self.type) {
        case .some(.sequential):
            let activities = self.taskList.flatMap { task in
                return CTFActivity(json: task)
            }
            
            return activities.first
            
        case .some(.random):
            let activities = self.taskList.flatMap { task in
                return CTFActivity(json: task)
            }
            
            return activities.random()
            
        case .some(.selectOneByDate):
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = DateFormatter.Style.full
            let dateString = dateFormatter.string(from: Date())
            
//            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
//            var convertedDate = dateFormatter.stringFromDate(currentDate)
            let hash = (dateString + CTFScheduleItem.myUUID).hashValue
            return self.recursivelySelectByHash(hash: hash, tasks: self.taskList)
            
            
        default:
            return nil
        }
    }
    
    func generateScheduledActivity() -> CTFScheduledActivity? {
        guard let activity = self.selectActivity()
            else {
            return nil
        }
        
        return CTFScheduledActivity(guid: self.guid, title: self.title, activity: activity, timeEstimate: self.timeEstimate)
    }
    
    
    

}
