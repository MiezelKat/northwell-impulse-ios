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


class CTFActivityTableViewController: UITableViewController, StoreSubscriber {

    static let kActivitiesFileName = "activities"
    static let kTrialActivitiesFileName = "trialActivities"
    static let kThankYouActivities = "thankYouActivity"
    
    var activitiesSchedule: CTFSchedule?
    var activities: [CTFScheduleItem] = []
    
    var trialActivitiesSchedule: CTFSchedule?
    var trialActivities: [CTFScheduleItem] = []

    var thankYouActivitiesSchedule: CTFSchedule?
    var thankYouActivity: CTFScheduleItem?
    
    var state: CTFReduxState?
    
    var store: Store<CTFReduxState>? {
        if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
            return appDelegate.reduxStoreManager?.store
        }
        else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.activitiesSchedule = self.loadSchedule(filename: CTFActivityTableViewController.kActivitiesFileName)
        self.trialActivitiesSchedule = self.loadSchedule(filename: CTFActivityTableViewController.kTrialActivitiesFileName)
        self.thankYouActivitiesSchedule = self.loadSchedule(filename: CTFActivityTableViewController.kThankYouActivities)
        
        self.store?.subscribe(self)
        if let state = self.store?.state {
            self.loadData(state: state)
        }
    
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    func newState(state: CTFReduxState) {
        let oldState = self.state
        self.state = state
        //possibly reload data
        if let oldState = oldState,
            CTFSelectors.shouldReloadActivities(newState: state, oldState: oldState){
            self.reloadData(state: state)
        }
        else {
            self.reloadData(state: state)
        }
        
    }
    
    
    func loadSchedule(filename: String) -> CTFSchedule? {
        guard let json = CTFTaskBuilderManager.getJson(forFilename: filename) as? JSON else {
            return nil
        }
        
        return CTFSchedule(json: json)
    }

    func loadData(state: CTFReduxState) {
        
        self.activities = self.activitiesSchedule?.items.filter(self.scheduledItemsFilter(state: state)) ?? []
        self.trialActivities = self.trialActivitiesSchedule?.items.filter(self.trialItemsFilter(state: state)) ?? []
        
        
        if self.activities.isEmpty,
            let thankYouActivity = self.thankYouActivitiesSchedule?.items.first {
            
            self.activities = [thankYouActivity]
            
        }
        
    }
    
    func reloadData(state: CTFReduxState) {
        self.loadData(state: state)
        self.reloadFinished()
    }
    
    func reloadFinished() {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let state = self.state {
            return self.trialActivities.count > 0 ? 2 : 1
        }
        else {
            return 1
        }
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
        activityCell.complete = false
        activityCell.timeLabel?.text = nil
        activityCell.subtitleLabel.text = nil

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
        self.store?.dispatch(action)
        
    }
    
    func scheduledItemsFilter(state: CTFReduxState) -> (CTFScheduleItem) -> Bool {
        
        return { scheduleItem in
            
            if state.debugMode {
                return true
            }
            
            switch(scheduleItem.identifier) {
            case "baseline":
                return CTFSelectors.shouldShowBaselineSurvey(state)
            case "reenrollment":
                return CTFSelectors.shouldShowReenrollmentSurvey(state)
            case "21-day-assessment":
                return CTFSelectors.shouldShow21DaySurvey(state)
            case "am_survey":
                return CTFSelectors.shouldShowMorningSurvey(state)
            case "pm_survey":
                return CTFSelectors.shouldShowEveningSurvey(state)
                
            default:
                return false
            }
            
        }
    }
    
    func trialItemsFilter(state: CTFReduxState) -> (CTFScheduleItem) -> Bool {
        return { scheduleItem in
            
            return state.shouldShowTrialActivities || state.debugMode
        }
    }


    
}
