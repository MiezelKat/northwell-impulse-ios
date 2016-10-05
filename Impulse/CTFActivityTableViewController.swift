//
//  CTFActivityTableViewController.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK

//public protocol SBAScheduledActivityDataSource: class {
//
//    func reloadData()
//    func numberOfSections() -> Int
//    func numberOfRowsInSection(section: Int) -> Int
//    func scheduledActivityAtIndexPath(indexPath: NSIndexPath) -> SBBScheduledActivity?
//    func shouldShowTaskForIndexPath(indexPath: NSIndexPath) -> Bool
//
//    optional func didSelectRowAtIndexPath(indexPath: NSIndexPath)
//    optional func sectionTitle(section: Int) -> String?
//}

public protocol CTFScheduledActivityDataSource: SBAScheduledActivityDataSource {
    func ctfScheduledActivityAtIndexPath(_ indexPath: IndexPath) -> CTFScheduledActivity?
}

class CTFActivityTableViewController: SBAActivityTableViewController {

    override var scheduledActivityDataSource: SBAScheduledActivityDataSource {
        return _scheduledActivityManager
    }
    
    lazy fileprivate var _scheduledActivityManager : CTFScheduledActivityManager = {
        guard let filePath = Bundle.main.path(forResource: "tasks_and_schedules", ofType: "json")
            else {
                fatalError("Unable to locate file tasks_and_schedules")
        }
        
        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            else {
                fatalError("Unable to create NSData with file content (PAM data)")
        }
        
        let tasksAndSchedules = try! JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        return CTFScheduledActivityManager(delegate: self, json: tasksAndSchedules as AnyObject)
    }()
    
    
    
    override func configure(cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        guard let activityCell = cell as? CTFActivityTableViewCell,
            let scheduledActivityDataSource = self.scheduledActivityDataSource as? CTFScheduledActivityDataSource,
            let schedule = scheduledActivityDataSource.ctfScheduledActivityAtIndexPath(indexPath) else {
                return
        }
        
        // The only cell type that is supported in the base implementation is an SBAActivityTableViewCell
        activityCell.titleLabel.text = schedule.activity?.label
        
        
//        let activity = schedule.activity
//        activityCell.complete = schedule.isCompleted
//        activityCell.titleLabel.text = activity.label
//        
//        activityCell.timeLabel?.text = schedule.scheduledTime
//        
//        // Show a detail that is most appropriate to the schedule status
//        if schedule.isCompleted {
//            let format = Localization.localizedString("SBA_ACTIVITY_SCHEDULE_COMPLETE_%@")
//            let dateString = NSDateFormatter.localizedStringFromDate(schedule.finishedOn, dateStyle: .LongStyle, timeStyle: .ShortStyle)
//            activityCell.subtitleLabel.text = String.localizedStringWithFormat(format, dateString)
//        }
//        else if schedule.isExpired {
//            let format = Localization.localizedString("SBA_ACTIVITY_SCHEDULE_EXPIRED_%@")
//            let dateString = schedule.isToday ? schedule.expiresTime! : NSDateFormatter.localizedStringFromDate(schedule.expiresOn, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
//            activityCell.subtitleLabel.text = String.localizedStringWithFormat(format, dateString)
//        }
//        else if schedule.isToday || schedule.isTomorrow {
//            activityCell.subtitleLabel.text = activity.labelDetail
//        }
//        else {
//            let format = Localization.localizedString("SBA_ACTIVITY_SCHEDULE_DETAIL_%@_UNTIL_%@")
//            let dateString = NSDateFormatter.localizedStringFromDate(schedule.scheduledOn, dateStyle: .LongStyle, timeStyle: .NoStyle)
//            activityCell.subtitleLabel.text = String.localizedStringWithFormat(format, dateString, schedule.expiresTime!)
//        }
//        
//        // Modify the label colors if disabled
//        if (scheduledActivityDataSource.shouldShowTaskForIndexPath(indexPath)) {
//            activityCell.titleLabel.textColor = UIColor.blackColor()
//        }
//        else {
//            activityCell.titleLabel.textColor = UIColor.grayColor()
//        }
    }
}
