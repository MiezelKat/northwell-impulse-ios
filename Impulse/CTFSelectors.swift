//
//  CTFSelectors.swift
//  Impulse
//
//  Created by James Kizer on 2/21/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit

class CTFSelectors: NSObject {
    
    static func isLoggedIn(_ state: CTFReduxState) -> Bool {
        return state.loggedIn
    }
    
    static func isLoaded(_ state: CTFReduxState) -> Bool {
        return state.loaded
    }
    
    static func sessionToken(_ state: CTFReduxState) -> String?  {
        return state.sessionToken
    }
    
    static func email(_ state: CTFReduxState) -> String?  {
        return state.email
    }
    
    static func password(_ state: CTFReduxState) -> String?  {
        return state.password
    }
    
    static func shouldShowBaselineSurvey(_ state: CTFReduxState) -> Bool {
        return state.baselineCompletedDate == nil
    }
    
    static func shouldShowReenrollmentSurvey(_ state: CTFReduxState) -> Bool {
        return state.baselineCompletedDate == nil
    }
    
    static public func shouldShow21DaySurvey(_ state: CTFReduxState) -> Bool {
        
        guard let baselineDate = state.baselineCompletedDate else {
            return false
        }
        
        //show am survey if the following are true
        //1) at least k21DayInterval since baseline has been completed
        //2) 21 day survey has not been completed
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        
        //1
        if timeSinceBaseline <= CTFStudyConstants.k21DaySurveyDelayInterval {
            return false
        }
        
        //2
        return state.day21CompletionDate == nil
        
    }
    
    static func shouldShowCompletionEmail(_ state: CTFReduxState) -> Bool {
        return state.day21CompletionDate != nil && state.completionEmailDate == nil
    }
    
    static public func morningSurveyTimeComponents(_ state: CTFReduxState) -> DateComponents? {
        return state.morningSurveyTimeComponents
    }
    
    static public func shouldShowMorningSurvey(_ state: CTFReduxState) -> Bool {
        
        //show am survey if the following are true
        //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
        //2) we are in the time range that the survey should be shown
        //3) survey has not yet been completed today
        
        //1
        guard let baselineDate = state.baselineCompletedDate else {
            return false
        }
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        guard timeSinceBaseline > CTFStudyConstants.kDailySurveyDelaySinceBaselineTimeInterval else {
            return false
        }
        
        //2
        guard let morningSurveyTimeComponents = morningSurveyTimeComponents(state),
            let todaysMorningSurveyTime = CTFActionCreators.combineDateWithDateComponents(date: Date(), timeComponents: morningSurveyTimeComponents as NSDateComponents) else {
                return false
        }
 
        let lowerDate = Date(timeIntervalSinceNow: -1.0 * CTFStudyConstants.kDailySurveyTimeAfterInterval)
        let upperDate = Date(timeIntervalSinceNow: CTFStudyConstants.kDailySurveyTimeBeforeInterval)
        let dateRange = Range(uncheckedBounds: (lower: lowerDate, upper: upperDate))
        if !dateRange.contains(todaysMorningSurveyTime as Date) {
            return false
        }
        
        //3 (note: if never taken, automatic true)
        //if it has been taken, it will be in today's range
        if let latestSurveyTime = state.lastMorningCompletionDate {
            return !dateRange.contains(latestSurveyTime as Date)
        }
        else {
            return true
        }
    }
    
    static public func eveningSurveyTimeComponents(_ state: CTFReduxState) -> DateComponents? {
        return state.eveningSurveyTimeComponents
    }
    
    static public func shouldShowEveningSurvey(_ state: CTFReduxState) -> Bool {
        
        //show am survey if the following are true
        //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
        //2) we are in the time range that the survey should be shown
        //3) survey has not yet been completed today
        
        //1
        guard let baselineDate = state.baselineCompletedDate else {
            return false
        }
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        guard timeSinceBaseline > CTFStudyConstants.kDailySurveyDelaySinceBaselineTimeInterval else {
            return false
        }
        
        //2
        guard let eveningSurveyTimeComponents = eveningSurveyTimeComponents(state),
            let todaysEveningSurveyTime = CTFActionCreators.combineDateWithDateComponents(date: Date(), timeComponents: eveningSurveyTimeComponents as NSDateComponents) else {
                return false
        }
        
        let lowerDate = Date(timeIntervalSinceNow: -1.0 * CTFStudyConstants.kDailySurveyTimeAfterInterval)
        let upperDate = Date(timeIntervalSinceNow: CTFStudyConstants.kDailySurveyTimeBeforeInterval)
        let dateRange = Range(uncheckedBounds: (lower: lowerDate, upper: upperDate))
        if !dateRange.contains(todaysEveningSurveyTime as Date) {
            return false
        }
        
        //3 (note: if never taken, automatic true)
        //if it has been taken, it will be in today's range
        if let latestSurveyTime = state.lastEveningCompletionDate {
            return !dateRange.contains(latestSurveyTime as Date)
        }
        else {
            return true
        }
    }
    
    static func shouldReloadActivities(newState: CTFReduxState, oldState: CTFReduxState) -> Bool {
        return (newState.baselineCompletedDate != oldState.baselineCompletedDate) ||
            (newState.day21CompletionDate != oldState.day21CompletionDate) ||
            (newState.morningSurveyTimeComponents != oldState.morningSurveyTimeComponents) ||
            (newState.lastMorningCompletionDate != oldState.lastMorningCompletionDate) ||
            (newState.eveningSurveyTimeComponents != oldState.eveningSurveyTimeComponents) ||
            (newState.lastEveningCompletionDate != oldState.lastEveningCompletionDate)  ||
            (newState.shouldShowTrialActivities != oldState.shouldShowTrialActivities)  ||
            (newState.debugMode != oldState.debugMode)
    }

    static func getValueInExtensibleStorage(_ state: CTFReduxState) -> (String) -> NSSecureCoding? {
        return { key in
            return state.extensibleStorage[key] as? NSSecureCoding
        }
    }
    
    static func baselineCompletedDate(_ state: CTFReduxState) -> Date? {
        return state.baselineCompletedDate
    }
    
    static func showTrialActivities(_ state: CTFReduxState) -> Bool {
        return state.shouldShowTrialActivities
    }
    
    static func debugMode(_ state: CTFReduxState) -> Bool {
        return state.debugMode
    }
    
    static func showDebugSwitch(_ state: CTFReduxState) -> Bool {
        return state.shouldShowDebugSwitch
    }
    
    static func shouldClearNotifications(_ state: CTFReduxState) -> Bool {
        
        //returns true if closeout survey completed and
        //any notifications are still set
        return state.day21CompletionDate != nil && (
            state.morningNotificationFireDate != nil ||
            state.morning2ndNotificationFireDate != nil ||
            state.eveningNotificationFireDate != nil ||
            state.evening2ndNotificationFireDate != nil ||
            state.day21NotificationFireDate != nil ||
            state.day212ndNotificationFireDate != nil
        )
    }
    
    
    
}


