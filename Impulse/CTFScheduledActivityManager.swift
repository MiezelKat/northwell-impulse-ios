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

class CTFScheduledActivityManager: NSObject, SBASharedInfoController, ORKTaskViewControllerDelegate, SBAScheduledActivityDataSource, CTFScheduledActivityDataSource {
    

    

    
    

    weak var delegate: SBAScheduledActivityManagerDelegate?
    
    override init() {
        super.init()
    }

    
    init(delegate: SBAScheduledActivityManagerDelegate?, json: AnyObject) {
        super.init()
        self.delegate = delegate
        
        print(json)
        
        guard let scheduleArray = json["schedules"] as? [AnyObject] else {
            return
        }
 
        self.scheduleItems = scheduleArray.flatMap( {CTFScheduleItem(json: $0)})
        self.reloadData()
    }
    
    lazy var sharedAppDelegate: SBAAppInfoDelegate = {
        return UIApplication.shared.delegate as! SBAAppInfoDelegate
    }()
    
    var bridgeInfo: SBABridgeInfo {
        return self.sharedBridgeInfo
    }
    
    var scheduleItems: [CTFScheduleItem]! = []
    var activities: [CTFScheduledActivity]! = []
    
    func reloadData() {
        //note that we will add filters in the future to only show items that should be shown based on context
        self.activities = self.scheduleItems.flatMap({$0.generateScheduledActivity()})
    }
    
    func numberOfSections() -> Int {
        return 1
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
            return 0
        }
    }
    
//    func scheduledActivityAtIndexPath(_ indexPath: NSIndexPath) -> SBBScheduledActivity? {
//        return nil
//    }
    
    func ctfScheduledActivityAtIndexPath(_ indexPath: IndexPath) -> CTFScheduledActivity? {
        return self.activities[(indexPath as NSIndexPath).row]
    }
    
    /**
     Should the task associated with the given index path be disabled.
     */
    @objc(shouldShowTaskForIndexPath:) public func shouldShowTask(for indexPath: IndexPath) -> Bool {
//        guard let schedule = scheduledActivityAtIndexPath(indexPath) where shouldShowTaskForSchedule(schedule)
//            else {
//                return false
//        }
        return true
    }
    
//    func shouldShowTaskForSchedule(schedule: SBBScheduledActivity) -> Bool {
//        // Allow user to perform a task again as long as the task is not expired
//        guard let taskRef = bridgeInfo.taskReferenceForSchedule(schedule) else { return false }
//        return !schedule.isExpired && (!schedule.isCompleted || taskRef.allowMultipleRun)
//    }
    
    func scheduledActivityForTaskViewController(_ taskViewController: ORKTaskViewController) -> CTFScheduledActivity? {
        guard let vc = taskViewController as? SBATaskViewController,
            let guid = vc.scheduledActivityGUID
            else {
                return nil
        }
        return activities.first(where: { $0.guid == guid })
    }
    
    func scheduledActivityForTaskIdentifier(_ taskIdentifier: String) -> CTFScheduledActivity? {
        return activities.first(where: { $0.activity!.identifier == taskIdentifier })
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
            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
            print(results)
        }
        
        self.reloadData()
        taskViewController.dismiss(animated: true) {}
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
//        if topLevelResults.filter({ $0.hasResults }).count > 0 {
//            let topResult = createActivityResult(taskResult.identifier, schedule: schedule, stepResults: topLevelResults)
//            allResults.insert(topResult, atIndex: 0)
//        }
        
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
        
        //note that at some point, we should probably 
        print(taskRef)
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
