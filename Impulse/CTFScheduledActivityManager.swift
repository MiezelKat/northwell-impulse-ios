//
//  CTFScheduledActivityManager.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK
import Bricoleur

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



let k1MinuteInterval: TimeInterval = 60.0
let k1HourInterval: TimeInterval = k1MinuteInterval * 60.0
let k1DayInterval: TimeInterval = 24.0 * k1HourInterval


let k21DaySurveyDelayInterval: TimeInterval = 21.0 * k1DayInterval
//let k21DaySurveyDelayInterval: TimeInterval = 21.0 * k1MinuteInterval


let kDailySurveyNotificationWindowBeforeInterval: TimeInterval = 0.0
let kDailySurveyNotificationWindowAfterInterval: TimeInterval = 30.0 * k1MinuteInterval
let kDailySurveyTimeBeforeInterval: TimeInterval = 2.0 * k1HourInterval
let kDailySurveyTimeAfterInterval: TimeInterval = 6.0 * k1HourInterval
let kDailySurveyDelaySinceBaselineTimeInterval: TimeInterval = 0.0
let kSecondaryNotificationDelay: TimeInterval = 2.0 * k1HourInterval
//let kDailySurveyDelaySinceBaselineTimeInterval: TimeInterval = 2.0 * k1MinuteInterval

let kThankYouGUID = "Thank-you-GUID"
let kThankYouText = "Thank you for today's input!"




class CTFScheduledActivityManager: NSObject, SBASharedInfoController, ORKTaskViewControllerDelegate, SBAScheduledActivityDataSource, CTFScheduledActivityDataSource {

    weak var delegate: SBAScheduledActivityManagerDelegate?
    var stepBuilder: BCLStepBuilder!
    
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
        
        let stepGeneratorServices: [BCLStepGenerator] = [
            BCLInstructionStepGenerator(),
            BCLTextFieldStepGenerator(),
            BCLIntegerStepGenerator(),
            BCLSingleChoiceStepGenerator(),
            BCLMultipleChoiceStepGenerator(),
            BCLTimePickerStepGenerator(),
            BCLFormStepGenerator(),
            CTFLikertFormStepGenerator(),
            CTFSemanticDifferentialFormStepGenerator(),
            PAMMultipleStepGenerator(),
            PAMStepGenerator(),
            CTFGoNoGoStepGenerator(),
            CTFBARTStepGenerator(),
            CTFDelayDiscountingStepGenerator(),
            BCLDefaultStepGenerator()
        ]
        
        let answerFormatGeneratorServices: [BCLAnswerFormatGenerator] = [
            BCLTextFieldStepGenerator(),
            BCLIntegerStepGenerator(),
            BCLTimePickerStepGenerator(),
            BCLSingleChoiceStepGenerator(),
            BCLMultipleChoiceStepGenerator()
        ]
        
        // Do any additional setup after loading the view, typically from a nib.
        self.stepBuilder = BCLStepBuilder(
            helper: nil,
            stepGeneratorServices: stepGeneratorServices,
            answerFormatGeneratorServices: answerFormatGeneratorServices)
 
        self.scheduleItems = scheduleArray.flatMap( {CTFScheduleItem(json: $0)})
        self.loadData()

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
        if self.activities.isEmpty {
            
            let thankYouActivity = CTFScheduledActivity(guid: kThankYouGUID, title: kThankYouText, activity: nil, timeEstimate: nil)!
            thankYouActivity.completed = true
            self.activities = [thankYouActivity]
        }
        
        self.trialActivities = self.scheduleItems.filter(self.trialItemsFilter).flatMap({ scheduledItem in
            let activity = scheduledItem.generateScheduledActivity()
            activity?.completed = CTFStateManager.defaultManager.isTrialActivityCompleted(guid: scheduledItem.guid)
            activity?.trial = true
            return activity
        })
    }
    
    func reloadData() {
        self.loadData()
        self.delegate?.reloadFinished(self)
    }
    
    func numberOfSections() -> Int {
        return CTFStateManager.defaultManager.shouldShowTrialActivities() ? 2 : 1
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
    
    func scheduledItemsFilter(scheduleItem: CTFScheduleItem) -> Bool {
        if scheduleItem.trial == true {
            return false
        }
        
        switch(scheduleItem.identifier) {
        case "baseline":
            return CTFStateManager.defaultManager.shouldShowBaselineSurvey()
            
        case "reenrollment":
            return CTFStateManager.defaultManager.shouldShowBaselineSurvey()
            
        case "21-day-assessment":
            return CTFStateManager.defaultManager.shouldShow21DaySurvey()
            
        case "am_survey":
            return CTFStateManager.defaultManager.shouldShowMorningSurvey()
            
        case "pm_survey":
            return CTFStateManager.defaultManager.shouldShowEveningSurvey() 
            
        default:
            return false
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
        guard let task = taskViewController.task
            else {
                return nil
        }
        
        return activities.first(where: { $0.guid == task.identifier }) ??
            self.trialActivities.first(where: { $0.guid == task.identifier })
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
            let schedule = self.scheduledActivityForTaskViewController(taskViewController) {
//            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
            
            let taskResult = taskViewController.result
            if let results = self.handleActivityResult(taskResult, schedule: schedule) {
                let archives = results.mapAndFilter({ self.archive(for: $0) })
                print(archives)
                SBADataArchive.encryptAndUploadArchives(archives)
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
//                assertionFailure("Failed to create task view controller for \(schedule)")
                return
        }
        
        self.delegate?.presentViewController(taskViewController, animated: true, completion: nil)
        
    }
    
    func createTaskViewControllerForSchedule(_ schedule: CTFScheduledActivity) -> ORKTaskViewController? {
        
        guard let activity = schedule.activity,
            let steps = self.stepBuilder.steps(forElementFilename: activity.fileName) else {
                return nil
        }
        
        let task = ORKOrderedTask(identifier: schedule.guid, steps: steps)
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        
        return taskViewController
        
    }

}

//Results Handling Extensions
//this would be better if we could come up with a way to register results handlers for each identifier
extension CTFScheduledActivityManager {
    
    func handleBaselineBehaviorResults(_ result: ORKTaskResult) {
        guard let stepResult = result.result(forIdentifier: "baseline_behaviors_4") as? ORKStepResult,
            let questionResult = stepResult.firstResult as? ORKChoiceQuestionResult,
            let answers = questionResult.choiceAnswers as? [String] else {
                return
        }
        
        let joinedAnswers = answers
            .map( { return $0.replacingOccurrences(of: "_bl_4", with: "")} )
            .joined(separator: ",") as NSString
        CTFKeychainHelpers.setKeychainObject(joinedAnswers, forKey: kBaselineBehaviorResults)
    }
    
    func handleBaselineSurvey(_ result: ORKTaskResult) {
        //1) set baseline completed date
        CTFStateManager.defaultManager.markBaselineSurveyAsCompleted(completedDate: result.endDate) 
        
        //extract morning and evening survey times
        
        if let notificationTimeResult = result.result(forIdentifier: "morning_notification_time_picker") as? ORKStepResult,
            let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer {
            
            CTFStateManager.defaultManager.setMorningSurveyTime(dateComponents)
        }
        
        if let notificationTimeResult = result.result(forIdentifier: "evening_notification_time_picker") as? ORKStepResult,
            let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer {
            
            CTFStateManager.defaultManager.setEveningSurveyTime(dateComponents)
        }
        
        
        //4) handle survey results
        
        //set Behavior full results
        self.handleBaselineBehaviorResults(result)
        
    }
    
    func handleReenrollment(_ result: ORKTaskResult) {
        
        if let notificationTimeResult = result.result(forIdentifier: "baseline_completed_date_picker") as? ORKStepResult,
            let dateQuestionResult = notificationTimeResult.firstResult as? ORKDateQuestionResult,
            let completedDate = dateQuestionResult.dateAnswer {
            
            CTFStateManager.defaultManager.markBaselineSurveyAsCompleted(completedDate: completedDate)
        }
        
        //extract morning and evening survey times
        
        if let notificationTimeResult = result.result(forIdentifier: "morning_notification_time_picker") as? ORKStepResult,
            let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer {
            
            CTFStateManager.defaultManager.setMorningSurveyTime(dateComponents)
        }
        
        if let notificationTimeResult = result.result(forIdentifier: "evening_notification_time_picker") as? ORKStepResult,
            let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
            let dateComponents = timeOfDayResult.dateComponentsAnswer {
            
            CTFStateManager.defaultManager.setEveningSurveyTime(dateComponents)
        }
        
        //set Behavior full results
        self.handleBaselineBehaviorResults(result)
    }
    
    func handleAMSurvey(_ result: ORKTaskResult) {
        //1) set latest AM survey completion
        CTFStateManager.defaultManager.markMorningSurveyCompleted(completedDate: result.endDate)

        
        //2) handle results
    }
    
    func getStepResults(forIdentifiers identifiers: [String], _ result: ORKTaskResult) -> [ORKStepResult] {
        return identifiers.flatMap { (identifier) -> ORKStepResult? in
            return result.stepResult(forStepIdentifier: identifier)
        }
    }
    
    func handlePMSurvey(_ result: ORKTaskResult, schedule: CTFScheduledActivity) -> [CTFActivityResult]? {
        
        CTFStateManager.defaultManager.markEveningSurveyCompleted(completedDate: result.endDate)
        
        var surveyResults: [String: AnyObject] = [:]
        //2) handle results
        
        let pmSurveyResults: [ORKStepResult] = self.getStepResults(forIdentifiers: ["pm_1", "pam_pm"], result)
        let pmSurveyActivityResult = self.createActivityResult("pm_survey_1", taskResult: result, schedule: schedule, stepResults: pmSurveyResults, schemaRevision: 6)
        
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
        
//        return [pmSurveyActivityResult]
        
        return nil
        
        
    }
    
    func handle21DaySurvey(_ result: ORKTaskResult) {
        
        CTFStateManager.defaultManager.mark21DaySurveyCompleted(completedDate: result.endDate)
        
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
        
        if schedule.trial {
            CTFStateManager.defaultManager.markTrialActivity(guid: schedule.guid, completed: true)
            return nil
        }
        
        switch(result.identifier) {
            
        case "Reenrollment":
            print(result)
            self.handleReenrollment(result)
            
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
