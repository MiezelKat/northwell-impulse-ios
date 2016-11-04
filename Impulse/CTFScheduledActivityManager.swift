//
//  CTFScheduledActivityManager.swift
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

let kMorningSurveyTime: String = "MorningSurveyTime"
let kEveningSurveyTime: String = "EveningSurveyTime"
let kLastMorningSurveyCompleted: String = "LastMorningSurveyCompleted"
let kLastEveningSurveyCompleted: String = "LastEveningSurveycompleted"
let kBaselineSurveyCompleted: String = "BaselineSurveyCompleted"
let k21DaySurveyCompleted: String = "21DaySurveyCompleted"

let k1MinuteInterval: TimeInterval = 60.0
let k1HourInterval: TimeInterval = k1MinuteInterval * 60.0
let k1DayInterval: TimeInterval = 24.0 * k1HourInterval


let k21DaySurveyDelayInterval: TimeInterval = 21.0 * k1DayInterval
//let k21DaySurveyDelayInterval: TimeInterval = 21.0 * k1MinuteInterval


let kDailySurveyTimeInterval: TimeInterval = 2.0 * k1HourInterval
let kDailySurveyDelaySinceBaselineTimeInterval: TimeInterval = 1.0 * k1HourInterval
//let kDailySurveyDelaySinceBaselineTimeInterval: TimeInterval = 2.0 * k1MinuteInterval

let kMorningNotificationIdentifer: String = "MorningNotification"
let kEveningNotificationIdentifer: String = "EveningNotification"
let k21DayNotificationIdentifier: String = "21DayNotification"

let kMorningNotificationText: String = "Hey, it's time to take your morning survey!"
let kEveningNotificationText: String = "Hey, it's time to take your evening survey!"
let k21DayNotificationText: String = "Hey, it's time to take your 21 day survey!"




class CTFScheduledActivityManager: NSObject, SBASharedInfoController, ORKTaskViewControllerDelegate, SBAScheduledActivityDataSource, CTFScheduledActivityDataSource {

    weak var delegate: SBAScheduledActivityManagerDelegate?
    
    override init() {
        super.init()
    }

    
    init(delegate: SBAScheduledActivityManagerDelegate?, json: AnyObject) {
        super.init()
        self.delegate = delegate
        
//        print(json)
        
        guard let scheduleArray = json["schedules"] as? [AnyObject] else {
            return
        }
 
        self.scheduleItems = scheduleArray.flatMap( {CTFScheduleItem(json: $0)})
        self.loadData()
        
        //check for firstRun
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            self.setNotificationsBasedOnKeychainState()
//            self.clearKeychain()
        }
        
        if let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications {
            scheduledNotifications.forEach({print($0)})
        }
        
        
        
    }
    
    lazy var sharedAppDelegate: SBAAppInfoDelegate = {
        return UIApplication.shared.delegate as! SBAAppInfoDelegate
    }()
    
    var bridgeInfo: SBABridgeInfo {
        return self.sharedBridgeInfo
    }
    
    var scheduleItems: [CTFScheduleItem]! = []
    var activities: [CTFScheduledActivity]! = []
    var trialActivities: [CTFScheduledActivity]! = []
    
    func loadData() {
        //note that we will add filters in the future to only show items that should be shown based on context
        self.activities = self.scheduleItems.filter(self.scheduledItemsFilter).flatMap({$0.generateScheduledActivity()})
        self.trialActivities = self.scheduleItems.filter(self.trialItemsFilter).flatMap({$0.generateScheduledActivity()})
    }
    
    func reloadData() {
        self.loadData()
        self.delegate?.reloadFinished(self)
    }
    
    func numberOfSections() -> Int {
        return 2
    }
    
    @objc(titleForSection:)
    public func title(for section: Int) -> String? {
        if section == 0 {
            return "Pending Activities"
        }
        else {
            return "Trial Activities"
        }
    }
    
    
    func setKeychainObject(_ object: NSSecureCoding, forKey key: String) {
        do {
            try ORKKeychainWrapper.setObject(object, forKey: key)
        } catch let error {
            assertionFailure("Got error \(error) when setting \(key)")
        }
    }
    
    func clearKeychain() {
        do {
            try ORKKeychainWrapper.resetKeychain()
        } catch let error {
            assertionFailure("Got error \(error) when resetting keychain")
        }
    }
    
    func getKeychainObject(_ key: String) -> NSSecureCoding? {
        
        var error: NSError?
        let o = ORKKeychainWrapper.object(forKey: key, error: &error)
        if error == nil {
            return o
        }
        else {
            print("Got error \(error) when getting \(key). This may just be the key has not yet been set!!")
            return nil
        }
    }
    
    
//    func numberOfRowsInSection(_ section: Int) -> Int {
//        return self.activities.count
//    }
    
    /**
     Number of rows in the data source.
     */
    @objc(numberOfRowsInSection:) public func numberOfRows(for section: Int) -> Int {
        if section == 0 {
            return self.activities.count
        }
        else {
            return self.trialActivities.count
        }
    }
    
//    func scheduledActivityAtIndexPath(_ indexPath: NSIndexPath) -> SBBScheduledActivity? {
//        return nil
//    }
    
    func ctfScheduledActivityAtIndexPath(_ indexPath: IndexPath) -> CTFScheduledActivity? {
        if (indexPath as NSIndexPath).section == 0 {
            return self.activities[(indexPath as NSIndexPath).row]
        }
        else {
            return self.trialActivities[(indexPath as NSIndexPath).row]
        }
        
    }
    
    func todayWithDateComponents(_ components: NSDateComponents) -> NSDate? {
        
        // *** define calendar components to use as well Timezone to UTC ***
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let calendar = Locale.current.calendar
        // *** Get components from date ***
        var todayComponents = calendar.dateComponents(unitFlags, from: Date())
        todayComponents.hour = components.hour
        todayComponents.minute = components.minute
        print("Components : \(todayComponents)")
        
        let returnDate = calendar.date(from: todayComponents)
        
        return returnDate != nil ? returnDate! as NSDate : nil
    }
    
    
    
    func scheduledItemsFilter(scheduleItem: CTFScheduleItem) -> Bool {
        if scheduleItem.trial == true {
            return false
        }
        
        let baselineCompletedDate = self.getKeychainObject(kBaselineSurveyCompleted) as? NSDate
        
        switch(scheduleItem.identifier) {
        case "baseline":
            //baseline shown if not yet completed
            return baselineCompletedDate == nil
        case "21-day-assessment":
            
            
            //show am survey if the following are true
            //1) at least k21DayInterval since baseline has been completed
            //2) 21 day survey has not been completed
            guard let baselineDate = baselineCompletedDate else {
                return false
            }
            
            let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
            
            //1
            if timeSinceBaseline <= k21DaySurveyDelayInterval {
                return false
            }
            
            //2
            return self.getKeychainObject(k21DaySurveyCompleted) == nil
            
        case "am_survey":
            
            //show am survey if the following are true
            //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
            //2) we are in the time range that the survey should be shown
            //3) survey has not yet been completed today
            
            //1
            guard let baselineDate = baselineCompletedDate else {
                return false
            }
            
//            let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
//            guard timeSinceBaseline > kDailySurveyDelaySinceBaselineTimeInterval else {
//                return false
//            }
            
            //2
            guard let morningSurveyTime = self.getKeychainObject(kMorningSurveyTime) as? NSDateComponents,
                let todaysMorningSurveyTime = self.todayWithDateComponents(morningSurveyTime)  else {
                    return false
            }
            
            let halfInterval = kDailySurveyTimeInterval / 2.0
            let lowerDate = Date(timeIntervalSinceNow: -1.0 * halfInterval)
            let upperDate = Date(timeIntervalSinceNow: halfInterval)
            let dateRange = Range(uncheckedBounds: (lower: lowerDate, upper: upperDate))
            if !dateRange.contains(todaysMorningSurveyTime as Date) {
                return false
            }
            
            //3 (note: if never taken, automatic true)
            //if it has been taken, it will be in today's range
            if let latestSurveyTime = self.getKeychainObject(kLastMorningSurveyCompleted) as? NSDate {
                return !dateRange.contains(latestSurveyTime as Date)
            }
            else {
                return true
            }
            
        case "pm_survey":
            
            //show am survey if the following are true
            //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
            //2) we are in the time range that the survey should be shown
            //3) survey has not yet been completed today
            
            //1
            guard let baselineDate = baselineCompletedDate else {
                return false
            }
            
//            let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
//            guard timeSinceBaseline > kDailySurveyDelaySinceBaselineTimeInterval else {
//                    return false
//            }
            
            //2
            guard let eveningSurveyTime = self.getKeychainObject(kEveningSurveyTime) as? NSDateComponents,
                let todaysMorningSurveyTime = self.todayWithDateComponents(eveningSurveyTime)  else {
                return false
            }
            
            let halfInterval = kDailySurveyTimeInterval / 2.0
            let lowerDate = Date(timeIntervalSinceNow: -1.0 * halfInterval)
            let upperDate = Date(timeIntervalSinceNow: halfInterval)
            let dateRange = Range(uncheckedBounds: (lower: lowerDate, upper: upperDate))
            if !dateRange.contains(todaysMorningSurveyTime as Date) {
                return false
            }
            
            //3 (note: if never taken, automatic true)
            //if it has been taken, it will be in today's range
            if let latestSurveyTime = self.getKeychainObject(kLastEveningSurveyCompleted) as? NSDate {
                return !dateRange.contains(latestSurveyTime as Date)
            }
            else {
                return true
            }
            
        default:
            return true
        }
    }
    
    func trialItemsFilter(scheduleItem: CTFScheduleItem) -> Bool {
        return scheduleItem.trial
    }
    
    /**
     Should the task associated with the given index path be disabled.
     */
    @objc(shouldShowTaskForIndexPath:) public func shouldShowTask(for indexPath: IndexPath) -> Bool {
        guard let schedule = self.ctfScheduledActivityAtIndexPath(indexPath),
            shouldShowTaskForSchedule(schedule: schedule)
            else {
                return false
        }
        return true
    }
    
    func shouldShowTaskForSchedule(schedule: CTFScheduledActivity) -> Bool {
        // Allow user to perform a task again as long as the task is not expired
//        guard let taskRef = bridgeInfo.taskReferenceForSchedule(schedule) else { return false }
//        return !schedule.isExpired && (!schedule.isCompleted || taskRef.allowMultipleRun)
        
        switch(schedule) {
        default:
            return true
        }
    }
    
    func scheduledActivityForTaskViewController(_ taskViewController: ORKTaskViewController) -> CTFScheduledActivity? {
        guard let vc = taskViewController as? SBATaskViewController,
            let guid = vc.scheduledActivityGUID
            else {
                return nil
        }
        return activities.first(where: { $0.guid == guid }) ??
            self.trialActivities.first(where: { $0.guid == guid })
    }
    
    func scheduledActivityForTaskIdentifier(_ taskIdentifier: String) -> CTFScheduledActivity? {
        return activities.first(where: { $0.activity!.identifier == taskIdentifier }) ??
            self.trialActivities.first(where: { $0.activity!.identifier == taskIdentifier })
    }
    
    
    /**
     The scheduled activity at the given index.
     @param indexPath   The index path for the schedule
     */
    @objc(scheduledActivityAtIndexPath:) public func scheduledActivity(at indexPath: IndexPath) -> SBBScheduledActivity? {
        assertionFailure("Not implemented")
        return nil
    }
    
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
//        if reason == ORKTaskViewControllerFinishReason.Completed,
//            let schedule = scheduledActivityForTaskViewController(taskViewController)
//            where shouldRecordResult(schedule, taskViewController: taskViewController) {
//            
//             Update any data stores associated with this task
//            taskViewController.task?.updateTrackedDataStores(shouldCommit: true)
//            
//             Archive the results
//            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
//            let archives = results.mapAndFilter({ archiveForActivityResult($0) })
//            SBADataArchive.encryptAndUploadArchives(archives)
//            
//             Update the schedule on the server
//            updateScheduledActivity(schedule, taskViewController: taskViewController)
//        }
//        else {
//            taskViewController.task?.updateTrackedDataStores(shouldCommit: false)
//        }
        
        if reason == ORKTaskViewControllerFinishReason.completed,
            let schedule = scheduledActivityForTaskViewController(taskViewController) {
//            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
            
            let taskResult = taskViewController.result
            if let results = self.handleActivityResult(taskResult, schedule: schedule) {
                let archives = results.mapAndFilter({ self.archive(for: $0) })
                //print(archives)
                //SBADataArchive.encryptAndUploadArchives(archives)
            }
            
            
        }
        
        self.reloadData()
        taskViewController.dismiss(animated: true) {}
    }
    
    @objc(archiveForActivityResult:)
    open func archive(for activityResult: CTFActivityResult) -> CTFActivityArchive? {
        if let archive = CTFActivityArchive(result: activityResult,
                                            jsonValidationMapping: nil) {
            do {
                try archive.complete()
                return archive
            }
            catch {}
        }
        return nil
    }
    
//    func defaultResultsParser()
    
    // Expose method for building results to allow for testing and subclass override
    func activityResultsForSchedule(_ schedule: CTFScheduledActivity, taskViewController: ORKTaskViewController) -> [CTFActivityResult] {
        
        // If no results, return empty array
        guard taskViewController.result.results != nil else { return [] }
        
        let taskResult = taskViewController.result
        let surveyTask = taskViewController.task as? SBASurveyTask
        
        // Look at the task result start/end date and assign the start/end date for the split result
        // based on whether or not the inputDate is greater/less than the comparison date. This way,
        // the split result will have a start date that is >= the overall task start date and an
        // end date that is <= the task end date.
        func outputDate(_ inputDate: Date?, comparison:ComparisonResult) -> Date {
            let compareDate = (comparison == .orderedAscending) ? taskResult.startDate : taskResult.endDate
            guard let date = inputDate , date.compare(compareDate) == comparison else {
                return compareDate
            }
            return date
        }
        
        // Function for creating each split result
        func createActivityResult(_ identifier: String, schedule: CTFScheduledActivity, stepResults: [ORKStepResult]) -> CTFActivityResult {
            let result = CTFActivityResult(taskIdentifier: identifier, taskRun: taskResult.taskRunUUID, outputDirectory: taskResult.outputDirectory)
            result.results = stepResults
            result.schedule = schedule
            result.startDate = outputDate(stepResults.first?.startDate, comparison: .orderedAscending)
            result.endDate = outputDate(stepResults.last?.endDate, comparison: .orderedDescending)
            result.schemaRevision = surveyTask?.schemaRevision ?? bridgeInfo.schemaReferenceWithIdentifier(identifier)?.schemaRevision ?? 1
            return result
        }
        
        // mutable arrays for ensuring all results are collected
        var topLevelResults:[ORKStepResult] = taskViewController.result.consolidatedResults()
        let resultsForIdentifier: [String: ORKStepResult] = topLevelResults.reduce([String: ORKStepResult]()) { (acc, result) in
            var returnDictionary = acc
            returnDictionary[result.identifier] = result
            return returnDictionary
        }
        print(resultsForIdentifier)
        var allResults:[CTFActivityResult] = []
//        var dataStores:[SBATrackedDataStore] = []
        
        if let task = taskViewController.task as? SBANavigableOrderedTask {
            print(task)
            for step in task.steps {
                print(step)
                
                if let subtaskStep = step as? SBASubtaskStep {
                    print(subtaskStep)
//                    var isDataCollection = false
//                    if let subtask = subtaskStep.subtask as? SBANavigableOrderedTask,
//                        let dataCollection = subtask.conditionalRule as? SBATrackedDataObjectCollection {
//                        // But keep a pointer to the dataStore
//                        dataStores.append(dataCollection.dataStore)
//                        isDataCollection = true
//                    }
                    
                    if  let taskId = subtaskStep.taskIdentifier,
                        let schemaId = subtaskStep.schemaIdentifier {
                        
                        // If this is a subtask step with a schemaIdentifier and taskIdentifier
                        // then split out the result
                        let (subResults, filteredResults) = subtaskStep.filteredStepResults(topLevelResults)
                        topLevelResults = filteredResults
                        
                        // Add filtered results to each collection as appropriate
                        let subschedule: CTFScheduledActivity = scheduledActivityForTaskIdentifier(taskId) ?? schedule
                        if subResults.count > 0 {
                            
                            // add dataStore results but only if this is not a data collection itself
                            let subsetResults = subResults
//                            if !isDataCollection {
//                                for dataStore in dataStores {
//                                    if let momentInDayResult = dataStore.momentInDayResult {
//                                        // Mark the start/end date with the start timestamp of the first step
//                                        for stepResult in momentInDayResult {
//                                            stepResult.startDate = subsetResults.first!.startDate
//                                            stepResult.endDate = stepResult.startDate
//                                        }
//                                        // Add the results at the beginning
//                                        subsetResults = momentInDayResult + subsetResults
//                                    }
//                                }
//                            }
                            
                            // create the subresult and add to list
                            let substepResult: CTFActivityResult = createActivityResult(schemaId, schedule: subschedule, stepResults: subsetResults)
                            allResults.append(substepResult)
                        }
                    }
//                    else if isDataCollection {
//                        
//                        // Otherwise, filter out the tracked object collection but do not create results
//                        // because this is tracked via the dataStore
//                        let (_, filteredResults) = subtaskStep.filteredStepResults(topLevelResults)
//                        topLevelResults = filteredResults
//                    }
                }
            }
        }
        
        // If there are any results that were not filtered into a subgroup then include them at the top level
        if topLevelResults.filter({ $0.hasResults }).count > 0 {
            let topResult = createActivityResult(taskResult.identifier, schedule: schedule, stepResults: topLevelResults)
            allResults.insert(topResult, at: 0)
        }
        
        return allResults
    }
    
    func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
        guard let schedule = ctfScheduledActivityAtIndexPath(indexPath) else { return }
//        guard isScheduleAvailable(schedule) else {
//            // Block performing a task that is scheduled for the future
//            let message = messageForUnavailableSchedule(schedule)
//            self.delegate?.showAlertWithOk(nil, message: message, actionHandler: nil)
//            return
//        }
        
        // If this is a valid schedule then create the task view controller
        guard let taskViewController = self.createTaskViewControllerForSchedule(schedule)
            else {
                assertionFailure("Failed to create task view controller for \(schedule)")
                return
        }
        
        self.delegate?.presentViewController(taskViewController, animated: true, completion: nil)
        
    }
    
    func createTask(_ schedule: CTFScheduledActivity) -> (task: ORKTask?, taskRef: SBATaskReference?) {
        
        let taskRef = bridgeInfo.taskReferenceWithIdentifier(schedule.activity.identifier)
        
        let task = taskRef?.transformToTask(with: CTFTaskFactory(), isLastStep: true)
        if let surveyTask = task as? SBASurveyTask {
            surveyTask.title = schedule.activity.title
        }
        return (task, taskRef)
    }
    
    func createTaskViewControllerForSchedule(_ schedule: CTFScheduledActivity) -> SBATaskViewController? {

        let (inTask, inTaskRef) = self.createTask(schedule)
        guard let task = inTask, let taskRef = inTaskRef else { return nil }
        let taskViewController = self.instantiateTaskViewController(task)
        self.setupTaskViewController(taskViewController, schedule: schedule, taskRef: taskRef)
        return taskViewController
    }
    
    func setupTaskViewController(_ taskViewController: SBATaskViewController, schedule: CTFScheduledActivity, taskRef: SBATaskReference) {
        taskViewController.scheduledActivityGUID = schedule.guid
        taskViewController.delegate = self
    }
    
    func instantiateTaskViewController(_ task: ORKTask) -> SBATaskViewController {
        return SBATaskViewController(task: task, taskRun: nil)
    }
}

//Results Handling Extensions
//this would be better if we could come up with a way to register results handlers for each identifier
extension CTFScheduledActivityManager {
    
    func cancelNotification(withIdentifier identifierToCancel: String) {
        if let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications {
            let notificationsToCancel = scheduledNotifications.filter({ (notification) -> Bool in
                guard let userInfo = notification.userInfo as? [String: AnyObject],
                    let identifer = userInfo["identifier"] as? String,
                    identifer == identifierToCancel else {
                        return false
                }
                return true
            })
            notificationsToCancel.forEach({ (notification) in
                UIApplication.shared.cancelLocalNotification(notification)
            })
        }
    }
    
    func setNotification(forIdentifier: String, initialFireDate: Date, text: String) {
        let notification = UILocalNotification()
        notification.userInfo = ["identifier": forIdentifier]
        notification.fireDate = initialFireDate
        notification.repeatInterval = NSCalendar.Unit.day
        notification.alertBody = text
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func setNotificationsBasedOnKeychainState() {
        
        //note that we may only wannt to do this if the 21 day has not yet been completed
        
        //morning notification
        //cancel notification if exists
        self.cancelNotification(withIdentifier: kMorningNotificationIdentifer)
        //Set notification
        if let dateComponents = self.getKeychainObject(kMorningSurveyTime) as? NSDateComponents,
            let fireDate = self.getInitialFireDate(forComponents: dateComponents) {
            self.setNotification(forIdentifier: kMorningNotificationIdentifer, initialFireDate: fireDate, text: kMorningNotificationText)
        }
        
        
        //evening notification
        //cancel notification if exists
        self.cancelNotification(withIdentifier: kEveningNotificationIdentifer)
        //Set notification
        if let dateComponents = self.getKeychainObject(kEveningSurveyTime) as? NSDateComponents,
            let fireDate = self.getInitialFireDate(forComponents: dateComponents) {
            self.setNotification(forIdentifier: kEveningNotificationIdentifer, initialFireDate: fireDate, text: kEveningNotificationText)
        }
        
        //21 day notification
        //cancel notification if exists
        self.cancelNotification(withIdentifier: k21DayNotificationIdentifier)
        
        //Set notification
        if let baselineDate = self.getKeychainObject(kBaselineSurveyCompleted) as? Date {
            let fireDate = Date(timeInterval: k21DaySurveyDelayInterval, since: baselineDate)
            self.setNotification(forIdentifier: k21DayNotificationIdentifier, initialFireDate: fireDate, text: k21DayNotificationText)
        }
    }
    
    func getInitialFireDate(forComponents components: NSDateComponents) -> Date? {
        guard let todaysNotificationDate = self.todayWithDateComponents(components as NSDateComponents) else {
            return nil
        }
        let timeUntilTodaysNotification = todaysNotificationDate.timeIntervalSinceNow
//        if timeUntilTodaysNotification > kDailySurveyDelaySinceBaselineTimeInterval {
        if timeUntilTodaysNotification > 0.0 {
            return todaysNotificationDate as Date
        }
        else {
            return Date(timeInterval: k1DayInterval, since: todaysNotificationDate as Date)
        }
    }
    
    func setMorningSurveyTime(_ result: ORKTaskResult) {
        if let notificationTimeResult = result.result(forIdentifier: "morning_notification_time_picker") as? ORKStepResult,
            let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer {
            
            //save morning survey time - note that we will only display morning survey +- 1 hr from this time
            self.setKeychainObject(dateComponents as NSDateComponents, forKey: kMorningSurveyTime)
            
            //set notifications
            //simple case, repeating notification for next 21 days at this time
            //Talk to Fred about this
            
            //cancel notification if exists
            self.cancelNotification(withIdentifier: kMorningNotificationIdentifer)
            
            //Set notification
            if let fireDate = self.getInitialFireDate(forComponents: dateComponents as NSDateComponents) {
                self.setNotification(forIdentifier: kMorningNotificationIdentifer, initialFireDate: fireDate, text: kMorningNotificationText)
            }
            
        }
    }
    
    func setEveningSurveyTime(_ result: ORKTaskResult) {
        if let notificationTimeResult = result.result(forIdentifier: "evening_notification_time_picker") as? ORKStepResult,
            let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer {
            
            //save morning survey time - note that we will only display morning survey +- 1 hr from this time
            self.setKeychainObject(dateComponents as NSDateComponents, forKey: kEveningSurveyTime)
            
            //set notifications
            //simple case, repeating notification for next 21 days at this time
            //Talk to Fred about this
            
            //cancel notification if exists
            self.cancelNotification(withIdentifier: kEveningNotificationIdentifer)
            
            //Set notification
            if let fireDate = self.getInitialFireDate(forComponents: dateComponents as NSDateComponents) {
                self.setNotification(forIdentifier: kEveningNotificationIdentifer, initialFireDate: fireDate, text: kEveningNotificationText)
            }
            
        }
    }
    
    func set21DaySurveyNotification(_ result: ORKTaskResult) {
        //cancel notification if exists
        self.cancelNotification(withIdentifier: k21DayNotificationIdentifier)
        
        //Set notification
        let fireDate = Date(timeIntervalSinceNow: k21DaySurveyDelayInterval)
        self.setNotification(forIdentifier: k21DayNotificationIdentifier, initialFireDate: fireDate, text: k21DayNotificationText)
    }
    
    
    
    
    func handleBaselineSurvey(_ result: ORKTaskResult) {
        //1) set baseline completed date
        let completedDate: NSDate = result.endDate as NSDate
        self.setKeychainObject(completedDate, forKey: kBaselineSurveyCompleted)
        
        //ask for permissions for notifications
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        //2) set 21 day notification
        self.set21DaySurveyNotification(result)
        
        //3) set am/pm notifications
//        self.handleAMPMNotificationResults(result)
        self.setMorningSurveyTime(result)
        self.setEveningSurveyTime(result)
        //4) handle survey results
        
    }
    
    func handleAMSurvey(_ result: ORKTaskResult) {
        //1) set latest AM survey completion
        let completedDate: NSDate = result.endDate as NSDate
        self.setKeychainObject(completedDate, forKey: kLastMorningSurveyCompleted)
        
        //2) handle results
    }
    
    func getStepResults(forIdentifiers identifiers: [String], _ result: ORKTaskResult) -> [ORKStepResult] {
        return identifiers.flatMap { (identifier) -> ORKStepResult? in
            return result.stepResult(forStepIdentifier: identifier)
        }
    }
    
    func handlePMSurvey(_ result: ORKTaskResult, schedule: CTFScheduledActivity) -> [CTFActivityResult]? {
        //1) set latest PM survey completion
        let completedDate: NSDate = result.endDate as NSDate
        self.setKeychainObject(completedDate, forKey: kLastEveningSurveyCompleted)
        
        
        var surveyResults: [String: AnyObject] = [:]
        //2) handle results
        
        let pmSurveyResults: [ORKStepResult] = self.getStepResults(forIdentifiers: ["pm_1", "pam_pm"], result)
        let pmSurveyActivityResult = self.createActivityResult("pm_survey_1", taskResult: result, schedule: schedule, stepResults: pmSurveyResults, schemaRevision: 4)
        
        let activeTaskResult: [ORKStepResult] = self.getStepResults(forIdentifiers: ["goNoGoStep", "BARTStep"], result)
        
        print(pmSurveyResults)
        print(activeTaskResult)
        
        
        /*
        if let eveningLikertResult = result.result(forIdentifier: "pm_1") as? ORKStepResult,
            let individualResults = eveningLikertResult.results{
            let pairs: [(String, Int)] = individualResults.flatMap({ (result) -> (String, Int)? in
                
                guard let scaleResult = result as? ORKScaleQuestionResult,
                    let intValue = scaleResult.scaleAnswer?.intValue else {
                    return nil
                }
                
                return (scaleResult.identifier, intValue)
            })
            
            if let resultDictionary: [String: Int] = pairs.toDict() {
                resultDictionary.forEach({ (identifier, answer) in
                    surveyResults[identifier] = answer as AnyObject?
                })
            }
        }
        */
        
        return [pmSurveyActivityResult]
        
        
    }
    
    func handle21DaySurvey(_ result: ORKTaskResult) {
        let completedDate: NSDate = result.endDate as NSDate
        self.setKeychainObject(completedDate, forKey: k21DaySurveyCompleted)
        
        //cancel 21 day survey notification
        self.cancelNotification(withIdentifier: k21DayNotificationIdentifier)
        
        //cancel other surveys too
        self.cancelNotification(withIdentifier: kMorningNotificationIdentifer)
        self.cancelNotification(withIdentifier: kEveningNotificationIdentifer)
        
    }
    
    func outputDate(_ inputDate: Date?, comparison:ComparisonResult, taskResult: ORKTaskResult) -> Date {
        let compareDate = (comparison == .orderedAscending) ? taskResult.startDate : taskResult.endDate
        guard let date = inputDate , date.compare(compareDate) == comparison else {
            return compareDate
        }
        return date
    }
    
    func createActivityResult(_ schemaIdentifier: String, taskResult: ORKTaskResult, schedule: CTFScheduledActivity, stepResults: [ORKStepResult], schemaRevision: Int) -> CTFActivityResult {
        let result = CTFActivityResult(taskIdentifier: schemaIdentifier, taskRun: taskResult.taskRunUUID, outputDirectory: taskResult.outputDirectory)
        result.results = stepResults
        result.schedule = schedule
        result.startDate = outputDate(stepResults.first?.startDate, comparison: .orderedAscending, taskResult: taskResult)
        result.endDate = outputDate(stepResults.last?.endDate, comparison: .orderedDescending, taskResult: taskResult)
        result.schemaRevision = schemaRevision as NSNumber?
        return result
    }
    
    func handleActivityResult(_ result: ORKTaskResult, schedule: CTFScheduledActivity) -> [CTFActivityResult]? {
        print(result)
        switch(result.identifier) {
            
        case "Baseline":
            print(result)
            self.handleBaselineSurvey(result)
            
        case "21Day":
            self.handle21DaySurvey(result)
            
        case let identifier where identifier.hasPrefix("am_survey"):
            self.handleAMSurvey(result)
            
        case let identifier where identifier.hasPrefix("pm_survey"):
            return self.handlePMSurvey(result, schedule: schedule)
            
        default: break
        }
        
        return nil
    }
    
//    func activityResultsHandler(_ results: [CTFActivityResult]) {
//        results.forEach(self.handleActivityResult)
//    }
    
}

extension SBASubtaskStep {
    func filteredTaskResult(_ inputResult: ORKTaskResult) -> ORKTaskResult {
        // create a mutated copy of the results that includes only the subtask results
        let subtaskResult: ORKTaskResult = inputResult.copy() as! ORKTaskResult
        if let stepResults = subtaskResult.results as? [ORKStepResult] {
            let (subtaskResults, _) = filteredStepResults(stepResults)
            subtaskResult.results = subtaskResults
        }
        return subtaskResult;
    }
    
    func filteredStepResults(_ inputResults: [ORKStepResult]) -> (subtaskResults:[ORKStepResult], remainingResults:[ORKStepResult]) {
        let prefix = "\(self.subtask.identifier)."
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        var subtaskResults:[ORKStepResult] = []
        var remainingResults:[ORKStepResult] = []
        for stepResult in inputResults {
            if (predicate.evaluate(with: stepResult)) {
                stepResult.identifier = stepResult.identifier.substring(from: prefix.endIndex)
                if let stepResults = stepResult.results {
                    for result in stepResults {
                        if result.identifier.hasPrefix(prefix) {
                            result.identifier = result.identifier.substring(from: prefix.endIndex)
                        }
                    }
                }
                subtaskResults += [stepResult]
            }
            else {
                remainingResults += [stepResult]
            }
        }
        return (subtaskResults, remainingResults)
    }
}
