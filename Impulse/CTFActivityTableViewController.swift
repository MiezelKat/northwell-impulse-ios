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
import ReSwift


class CTFActivityTableViewController: UITableViewController, CTFSettingsDelegate, StoreSubscriber {

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
        
        CTFReduxStoreManager.sharedInstance.store.subscribe(self)
        if let state = CTFReduxStoreManager.sharedInstance.store.state {
            self.loadData(state: state)
        }
    
    }
    
    deinit {
        CTFReduxStoreManager.sharedInstance.store.unsubscribe(self)
    }
    
    func shouldReloadData(state: CTFReduxStore) -> Bool {
        return false
    }
    
    func newState(state: CTFReduxStore) {
        
        //possibly reload data
        if self.shouldReloadData(state: state) {
            self.reloadData(state: state)
        }
        
    }
    
    
    func loadSchedule(filename: String) -> CTFSchedule? {
        guard let json = CTFTaskBuilderManager.getJson(forFilename: filename) as? JSON else {
            return nil
        }
        
        return CTFSchedule(json: json)
    }

    func loadData(state: CTFReduxStore) {
        
        self.activities = self.activitiesSchedule?.items.filter(self.scheduledItemsFilter(state: state)) ?? []
        self.trialActivities = self.activitiesSchedule?.items.filter(self.trialItemsFilter(state: state)) ?? []
        
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
    
    func reloadData(state: CTFReduxStore) {
        self.loadData(state: state)
        self.reloadFinished()
    }
    
    func reloadFinished() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    func settingsUpdated() {
//        self.reloadData()
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
    
    func scheduledItemsFilter(state: CTFReduxStore) -> (CTFScheduleItem) -> Bool {
        return { scheduleItem in
            switch(scheduleItem.identifier) {
            case "baseline":
                return CTFSelectors.shouldShowBaselineSurvey(state: state)
            default:
                return true
            }
            
        }
        

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
    
    func trialItemsFilter(state: CTFReduxStore) -> (CTFScheduleItem) -> Bool {
        return { scheduleItem in
            return true
        }
    }


    
}
