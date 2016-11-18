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

class CTFActivityTableViewController: SBAActivityTableViewController, CTFSettingsDelegate {

    override var scheduledActivityDataSource: SBAScheduledActivityDataSource {
        return _ctfScheduledActivityManager
    }
    
    lazy fileprivate var _ctfScheduledActivityManager : CTFScheduledActivityManager = {
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
        activityCell.titleLabel.text = schedule.title
        activityCell.complete = false
        activityCell.timeLabel?.text = ""
        activityCell.subtitleLabel?.text = schedule.timeEstimate
        
    }
    
    func showTrialsChanged(_ showTrials: Bool) {
        self.scheduledActivityDataSource.reloadData()
    }
    
    
}
