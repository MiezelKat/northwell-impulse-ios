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

class CTFActionCreators: NSObject {
    
    static let k1MinuteInterval: TimeInterval = 60.0
    static let k1HourInterval: TimeInterval = k1MinuteInterval * 60.0
    static let k1DayInterval: TimeInterval = 24.0 * k1HourInterval
    static let k21DaySurveyDelayInterval: TimeInterval = 21.0 * k1DayInterval
    
    static let kSecondaryNotificationDelay: TimeInterval = 2.0 * k1HourInterval
    
    static let kBaselineBehaviorResults: String = "BaselineBehaviorResults"
    
    static func handleBaselineSurvey(_ result: ORKTaskResult) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        return { (state, store) in
            //set baseline completed date
            let markBaselineAction = MarkBaselineSurveyCompletedAction(completedDate: result.endDate)
            CTFReduxStoreManager.mainStore.dispatch(markBaselineAction)
            
            //set 21 day notification
            let initialFireDate = Date(timeInterval: CTFActionCreators.k21DaySurveyDelayInterval, since: result.endDate)
            let secondaryFireDate = initialFireDate.addingTimeInterval(CTFActionCreators.kSecondaryNotificationDelay)
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
                let setBehaviorsAction = SetValueInExtensibleStorage(key: CTFActionCreators.kBaselineBehaviorResults, value: answers as NSObject)
                store.dispatch(setBehaviorsAction)
                
            }
            
            return nil
        }
    }
    
    // MARK: privates
    private static func setMorningSurveyTime(_ dateComponents: DateComponents) -> (CTFReduxState, Store<CTFReduxState>) -> Action? {
        
        return { (state, store) in
        
            print("morning date components: \(dateComponents)")

            let surveyTimeAction = SetMorningSurveyTimeAction(components: dateComponents)
            store.dispatch(surveyTimeAction)
            
            let lastCompletion: Date? = CTFReduxStoreManager.mainStore.state.lastMorningCompletionDate
            if let initialFireDate = CTFActionCreators.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFActionCreators.kSecondaryNotificationDelay)
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
            
            let lastCompletion: Date? = CTFReduxStoreManager.mainStore.state.lastEveningCompletionDate
            if let initialFireDate = CTFActionCreators.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
                let secondaryFireDate = initialFireDate.addingTimeInterval(CTFActionCreators.kSecondaryNotificationDelay)
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
    
    static private func combineDateWithDateComponents(date: Date, timeComponents: NSDateComponents) -> Date? {
        
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
        let fromDate = baseDate.addingTimeInterval(-1.0 * kDailySurveyNotificationWindowBeforeInterval)
        let toDate = baseDate.addingTimeInterval(kDailySurveyNotificationWindowAfterInterval)
        
        return Date.RandomDateBetween(from: fromDate, to: toDate)
        
    }
    

}
