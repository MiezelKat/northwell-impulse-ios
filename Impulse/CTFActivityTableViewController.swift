//
//  CTFActivityTableViewController.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import Gloss


class CTFActivityTableViewController: UITableViewController, CTFSettingsDelegate {

    static let kActivitiesFileName = "activities"
    static let kTrialActivitiesFileName = "trialActivities"
    
    var activitiesSchedule: CTFSchedule?
    var activities: [CTFScheduleItem] = []
    
    var trialActivitiesSchedule: CTFSchedule?
    var trialActivities: [CTFScheduleItem] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.activitiesSchedule = self.loadSchedule(filename: CTFActivityTableViewController.kActivitiesFileName)
        self.trialActivitiesSchedule = self.loadSchedule(filename: CTFActivityTableViewController.kTrialActivitiesFileName)
        self.loadData()
    }
    
    func loadSchedule(filename: String) -> CTFSchedule? {
        guard let json = CTFTaskBuilderManager.getJson(forFilename: filename) as? JSON else {
            return nil
        }
        
        return CTFSchedule(json: json)
    }
    
    
//    func loadTasksAndSchedulesJson() -> [String: Any]? {
//        
//        guard let filePath = Bundle.main.path(forResource: "tasks_and_schedules", ofType: "json")
//            else {
//                fatalError("Unable to locate file tasks_and_schedules")
//        }
//        
//        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath))
//            else {
//                fatalError("Unable to create NSData with file content (PAM data)")
//        }
//        
//        do {
//            return try JSONSerialization.jsonObject(with: fileContent, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
//            
//        } catch let error {
//            fatalError("Cannot load activities")
//        }
//        
//        return nil
//    }
//    
    func loadData() {
        
        self.activities = self.activitiesSchedule?.items.filter(self.scheduledItemsFilter) ?? []
        self.trialActivities = self.activitiesSchedule?.items.filter(self.trialItemsFilter) ?? []
        
//        self.activities = self.scheduleItems.filter(self.scheduledItemsFilter).flatMap({$0.generateScheduledActivity()})
//        if self.activities.isEmpty {
//            
//            let thankYouActivity = CTFScheduledActivity(guid: kThankYouGUID, title: kThankYouText, activity: nil, timeEstimate: nil)!
//            thankYouActivity.completed = true
//            self.activities = [thankYouActivity]
//        }
//        
//        self.trialActivities = self.scheduleItems.filter(self.trialItemsFilter).flatMap({ scheduledItem in
//            let activity = scheduledItem.generateScheduledActivity()
//            activity?.completed = CTFStateManager.defaultManager.isTrialActivityCompleted(guid: scheduledItem.guid)
//            activity?.trial = true
//            return activity
//        })
    }
    
    func reloadData() {
        self.loadData()
        self.reloadFinished()
    }
    
    func reloadFinished() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    func settingsUpdated() {
        self.reloadData()
    }
    
    func numberOfSections() -> Int {
        return CTFStateManager.defaultManager.shouldShowTrialActivities() ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pending Activities"
        }
        else {
            return "Trial Activities"
        }
    }
    
//    public func title(for section: Int) -> String? {
//        if section == 0 {
//            return "Pending Activities"
//        }
//        else {
//            return "Trial Activities"
//        }
//    }
    
    private func scheduleItem(forIndexPath indexPath: IndexPath) -> CTFScheduleItem? {
        if (indexPath as NSIndexPath).section == 0 {
            return self.activities[(indexPath as NSIndexPath).row]
        }
        else {
            return self.trialActivities[(indexPath as NSIndexPath).row]
        }
    }

    
    //MARK: Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.activities.count
        }
        else {
            return self.trialActivities.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let identifier = "ActivityCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        guard let activityCell = cell as? CTFActivityTableViewCell,
            let item = self.scheduleItem(forIndexPath: indexPath) else {
                return cell
        }
        
        activityCell.titleLabel.text = item.title

        return activityCell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = self.scheduleItem(forIndexPath: indexPath) else {
            return
        }
        
        let activityRun = CTFActivityRun(
            identifier: item.identifier,
            activity: item.activity as JsonElement,
            resultTransforms: item.resultTransforms,
            onCompletionActions: item.onCompletionActions)
        let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
        CTFReduxStoreManager.mainStore.dispatch(action)
        
    }
    
    func scheduledItemsFilter(scheduleItem: CTFScheduleItem) -> Bool {
        
        return true

//        switch(scheduleItem.identifier) {
//        case "baseline":
//            return CTFStateManager.defaultManager.shouldShowBaselineSurvey()
//            
//        case "reenrollment":
//            return CTFStateManager.defaultManager.shouldShowBaselineSurvey()
//            
//        case "21-day-assessment":
//            return CTFStateManager.defaultManager.shouldShow21DaySurvey()
//            
//        case "am_survey":
//            return CTFStateManager.defaultManager.shouldShowMorningSurvey()
//            
//        case "pm_survey":
//            return CTFStateManager.defaultManager.shouldShowEveningSurvey()
//            
//        default:
//            return false
//        }
    }
    
    func trialItemsFilter(scheduleItem: CTFScheduleItem) -> Bool {
        return true
    }


    
}
