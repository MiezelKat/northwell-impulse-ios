//
//  CTFActionCreators.swift
//  Impulse
//
//  Created by James Kizer on 2/20/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit
import ResearchSuiteExtensions


class CTFActionCreators: NSObject {
    
    public typealias ActionCreator = (_ state: CTFReduxState, _ store: Store<CTFReduxState>) -> Action?
    public typealias AsyncActionCreator = (
        _ state: CTFReduxState,
        _ store: Store<CTFReduxState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void

    static func setAppLoaded(loaded: Bool) -> AsyncActionCreator {
        return { (state, store, actionCreatorCallback) in
            
            let appLoadedAction = SetAppLoadedAction(loaded: loaded)
            actionCreatorCallback( { (store, state) in
                return appLoadedAction
            })
            
        }
    }
    
    static func setLoggedIn(loggedIn: Bool) -> AsyncActionCreator {
        return { (state, store, actionCreatorCallback) in
            
            let loggedInAction = SetLoggedInAction(loggedIn: loggedIn)
            actionCreatorCallback( { (store, state) in
                return loggedInAction
            })
            
        }
    }
    
    static func setBridgeCredentials(sessionToken: String?, email: String?, password: String?) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            return SetBridgeCredentialsAction(sessionToken: sessionToken, email: email, password: password)
        }
    }
    
    static func completeActivity(uuid: UUID, activityRun: CTFActivityRun, taskResult: ORKTaskResult?) -> AsyncActionCreator {
        return { (state, store, actionCreatorCallback) in
                        
            //process a bunch of actions
            if let taskResult = taskResult {
                switch(activityRun.identifier) {
                case "baseline":
                    store.dispatch(CTFActionCreators.handleBaselineSurvey(taskResult))
                case "reenrollment":
                    store.dispatch(CTFActionCreators.handleReenrollment(taskResult))
                case "21-day-assessment":
                    store.dispatch(CTFActionCreators.handleDay21Survey(taskResult))
                case "am_survey":
                    store.dispatch(CTFActionCreators.handleMorningSurvey(taskResult))
                case "pm_survey":
                    store.dispatch(CTFActionCreators.handleEveningSurvey(taskResult))
                case "set_morning_survey":
                    store.dispatch(CTFActionCreators.handleSetMorningSurveyTime(taskResult))
                case "set_evening_survey":
                    store.dispatch(CTFActionCreators.handleSetEveningSurveyTime(taskResult))
                    
                default:
                    break
                }
            }
            
            let completeAction = CompleteActivityAction(uuid: uuid, activityRun: activityRun, taskResult: taskResult)
            actionCreatorCallback( { (store, state) in
                return completeAction
            })
            
        }
    }
    
    static func handleBaselineSurvey(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            //set baseline completed date
            let markBaselineAction = MarkBaselineSurveyCompletedAction(completedDate: result.endDate)
            store.dispatch(markBaselineAction)
            
            if let stepResult = result.result(forIdentifier: "group_label") as? ORKStepResult,
                let groupLabelResult = stepResult.firstResult as? ORKTextQuestionResult,
                let groupLabel = groupLabelResult.textAnswer {
                
                store.dispatch(setGroupLabel(groupLabel))
            }
            
            //set 21 day notification
            let initialFireDate = Date(timeInterval: CTFStudyConstants.k21DaySurveyDelayInterval, since: result.endDate)
            let secondaryFireDate = initialFireDate.addingTimeInterval(CTFStudyConstants.kSecondaryNotificationDelay)
            let day21NotificationAction = Set21DayNotificationAction(
                initialFireDate: initialFireDate,
                secondaryFireDate: secondaryFireDate)
            
            store.dispatch(day21NotificationAction)
            
            //
            if let notificationTimeResult = result.result(forIdentifier: "morning_notification_time_picker") as? ORKStepResult,
                let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
                let dateComponents = timeOfDayResult.dateComponentsAnswer {
                
                store.dispatch(setMorningSurveyTime(dateComponents))
            }
            
            if let notificationTimeResult = result.result(forIdentifier: "evening_notification_time_picker") as? ORKStepResult,
                let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
                let dateComponents = timeOfDayResult.dateComponentsAnswer {
                
                store.dispatch(setEveningSurveyTime(dateComponents))
            }
            
            if let stepResult = result.result(forIdentifier: "baseline_behaviors_4") as? ORKStepResult,
                let questionResult = stepResult.firstResult as? ORKChoiceQuestionResult,
                let answers = questionResult.choiceAnswers as? [String],
                answers.count > 0 {
                
//                let secureCodingAnswers = answers as NSObject
//                debugPrint(secureCodingAnswers)
                let setBehaviorsAction = SetValueInExtensibleStorage(key: CTFStudyConstants.kBaselineBehaviorResults, value: answers as NSObject)
                store.dispatch(setBehaviorsAction)
                
            }
            
            return nil
        }
    }
    
    static func handleReenrollment(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            
            if let notificationTimeResult = result.result(forIdentifier: "baseline_completed_date_picker") as? ORKStepResult,
                let dateQuestionResult = notificationTimeResult.firstResult as? ORKDateQuestionResult,
                let completedDate = dateQuestionResult.dateAnswer {
                
                //set baseline completed date
                let markBaselineAction = MarkBaselineSurveyCompletedAction(completedDate: completedDate)
                store.dispatch(markBaselineAction)
                
                //set 21 day notification
                let initialFireDate = Date(timeInterval: CTFStudyConstants.k21DaySurveyDelayInterval, since: completedDate)
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFStudyConstants.kSecondaryNotificationDelay)
                let day21NotificationAction = Set21DayNotificationAction(
                    initialFireDate: initialFireDate,
                    secondaryFireDate: secondaryFireDate)
                
                store.dispatch(day21NotificationAction)
            }
            
            if let stepResult = result.result(forIdentifier: "group_label") as? ORKStepResult,
                let groupLabelResult = stepResult.firstResult as? ORKTextQuestionResult,
                let groupLabel = groupLabelResult.textAnswer {
                
                store.dispatch(setGroupLabel(groupLabel))
            }
            
            //
            if let notificationTimeResult = result.result(forIdentifier: "morning_notification_time_picker") as? ORKStepResult,
                let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
                let dateComponents = timeOfDayResult.dateComponentsAnswer {
                
                store.dispatch(setMorningSurveyTime(dateComponents))
            }
            
            if let notificationTimeResult = result.result(forIdentifier: "evening_notification_time_picker") as? ORKStepResult,
                let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
                let dateComponents = timeOfDayResult.dateComponentsAnswer {
                
                store.dispatch(setEveningSurveyTime(dateComponents))
            }
            
            if let stepResult = result.result(forIdentifier: "baseline_behaviors_4") as? ORKStepResult,
                let questionResult = stepResult.firstResult as? RSEnhancedMultipleChoiceResult,
                let answers: [NSString] = questionResult.choiceAnswers?.flatMap({ $0.value as? NSString }),
                answers.count > 0 {
                
                //                let secureCodingAnswers = answers as NSObject
                //                debugPrint(secureCodingAnswers)
                let answersWithoutSuffix = answers.map { $0.replacingOccurrences(of: "_bl_4", with: "") }
                let setBehaviorsAction = SetValueInExtensibleStorage(key: CTFStudyConstants.kBaselineBehaviorResults, value: answersWithoutSuffix as NSObject)
                store.dispatch(setBehaviorsAction)
                
            }
            
            return nil
        }
    }
    
    static func handleMorningSurvey(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            
            assert(state.morningSurveyTimeComponents != nil, "date components should exist here")
            
            if let dateComponents = state.morningSurveyTimeComponents,
                let initialFireDate = CTFActionCreators.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: result.endDate) {
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFStudyConstants.kSecondaryNotificationDelay)
                let notificationAction = SetMorningNotificationAction(
                    initialFireDate: initialFireDate,
                    secondaryFireDate: secondaryFireDate)
                
                store.dispatch(notificationAction)
            }
            
            return MarkMorningSurveyCompletedAction(completedDate: result.endDate)
            
        }
    }
    
    static func handleEveningSurvey(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            
            assert(state.morningSurveyTimeComponents != nil, "date components should exist here")
            
            if let dateComponents = state.eveningSurveyTimeComponents,
                let initialFireDate = CTFActionCreators.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: result.endDate) {
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFStudyConstants.kSecondaryNotificationDelay)
                let notificationAction = SetEveningNotificationAction(
                    initialFireDate: initialFireDate,
                    secondaryFireDate: secondaryFireDate)
                
                store.dispatch(notificationAction)
            }
            
            return MarkEveningSurveyCompletedAction(completedDate: result.endDate)
            
        }
    }
    
    static func handleDay21Survey(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            
            store.dispatch(ClearAllNotificationsAction())
            
            return MarkDay21SurveyCompletedAction(completedDate: result.endDate)
            
        }
    }
    
    static func setValueInExtensibleStorage(key: String, value: NSObject?) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        
        return { (state, store) in
            return SetValueInExtensibleStorage(key: key, value: value)
        }
        
    }
    
    static func clearStore() -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            return ClearStore()
        }
    }
    
    static func showTrialActivities(show: Bool) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            return SetShouldShowTrialActivities(show: show)
        }
    }
    
    static func setDebugMode(debugMode: Bool) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            return SetDebugModeAction(debugMode: debugMode)
        }
    }
    
    static func showDebugSwitch(show: Bool) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            return SetShouldShowDebugSwitch(show: show)
        }
    }
    
    static func handleSetMorningSurveyTime(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            
            guard let notificationTimeResult = result.result(forIdentifier: "morning_notification_time_picker") as? ORKStepResult,
                let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
                let dateComponents = timeOfDayResult.dateComponentsAnswer else {
                    return nil
            }
            
            store.dispatch(setMorningSurveyTime(dateComponents))
            return nil
        }
    }
    
    static func handleSetEveningSurveyTime(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            
            guard let notificationTimeResult = result.result(forIdentifier: "evening_notification_time_picker") as? ORKStepResult,
                let timeOfDayResult = notificationTimeResult.firstResult as? ORKTimeOfDayQuestionResult,
                let dateComponents = timeOfDayResult.dateComponentsAnswer else {
                    return nil
            }
            
            store.dispatch(setEveningSurveyTime(dateComponents))
            return nil
        }
    }
    
    private static func setGroupLabel(_ groupLabel: String) -> Action {
        return SetGroupLabel(groupLabel: groupLabel)
    }
    
    // MARK: privates
    private static func setMorningSurveyTime(_ dateComponents: DateComponents) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        
        return { (state, store) in
        
            print("morning date components: \(dateComponents)")

            let surveyTimeAction = SetMorningSurveyTimeAction(components: dateComponents)
            store.dispatch(surveyTimeAction)
            
            let lastCompletion: Date? = state.lastMorningCompletionDate
            if let initialFireDate = CTFActionCreators.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFStudyConstants.kSecondaryNotificationDelay)
                let notificationAction = SetMorningNotificationAction(
                    initialFireDate: initialFireDate,
                    secondaryFireDate: secondaryFireDate)
                
                store.dispatch(notificationAction)
            }
            
            return nil
        }
        
    }
    
    // MARK: privates
    private static func setEveningSurveyTime(_ dateComponents: DateComponents) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        
        return { (state, store) in
            
            print("evening date components: \(dateComponents)")
            
            let surveyTimeAction = SetEveningSurveyTimeAction(components: dateComponents)
            store.dispatch(surveyTimeAction)
            
            let lastCompletion: Date? = state.lastEveningCompletionDate
            if let initialFireDate = CTFActionCreators.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFStudyConstants.kSecondaryNotificationDelay)
                let notificationAction = SetEveningNotificationAction(
                    initialFireDate: initialFireDate,
                    secondaryFireDate: secondaryFireDate)
                
                store.dispatch(notificationAction)
            }
            
            return nil
            
        }
        
        
        
    }
    
//    static private func handleBaselineBehaviorResults(_ result: ORKTaskResult) {
//        guard let stepResult = result.result(forIdentifier: "baseline_behaviors_4") as? ORKStepResult,
//            let questionResult = stepResult.firstResult as? ORKChoiceQuestionResult,
//            let answers = questionResult.choiceAnswers as? [String],
//            answers.count > 0 else {
//                return
//        }
//        
//        let joinedAnswers = answers
//            .map( { return $0.replacingOccurrences(of: "_bl_4", with: "")} )
//            .joined(separator: ",") as NSString
//        CTFKeychainHelpers.setKeychainObject(joinedAnswers, forKey: kBaselineBehaviorResults)
//    }

    
    // MARK: Helper functions
    static private func dateComponents(forDate date: Date) -> DateComponents {
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let calendar = Locale.current.calendar
        // *** Get components from date ***
        return calendar.dateComponents(unitFlags, from: date)
    }
    
    static public func combineDateWithDateComponents(date: Date, timeComponents: NSDateComponents) -> Date? {
        
        // *** define calendar components to use as well Timezone to UTC ***
//        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let calendar = Locale.current.calendar
        // *** Get components from date ***
        var dateComponents = CTFActionCreators.dateComponents(forDate: date)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
//        print("Components : \(dateComponents)")

        return calendar.date(from: dateComponents)
    }
    
    static private func getNotificationFireDate(timeComponents: NSDateComponents, latestCompletion: Date?) -> Date? {
        
        guard let baseDate: Date = {
            if let latestCompletion = latestCompletion,
                latestCompletion.isToday {
                let tomorrow = Date().addingNumberOfDays(1)
                return CTFActionCreators.combineDateWithDateComponents(date: tomorrow, timeComponents: timeComponents)
            }
            else {
                return CTFActionCreators.combineDateWithDateComponents(date: Date(), timeComponents: timeComponents)
            }
            }() else {
                return nil
        }
        
        //select window around baseDate
        let fromDate = baseDate.addingTimeInterval(-1.0 * CTFStudyConstants.kDailySurveyNotificationWindowBeforeInterval)
        let toDate = baseDate.addingTimeInterval(CTFStudyConstants.kDailySurveyNotificationWindowAfterInterval)
        
        return Date.RandomDateBetween(from: fromDate, to: toDate)
        
    }
    
    
    

}
