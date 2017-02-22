//
//  CTFSelectors.swift
//  Impulse
//
//  Created by James Kizer on 2/21/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit

class CTFSelectors: NSObject {
    
    static func shouldShowBaselineSurvey(state: CTFReduxState) -> Bool {
        return state.baselineCompletedDate == nil
    }
    
    static func shouldShowReenrollmentSurvey(state: CTFReduxState) -> Bool {
        return state.baselineCompletedDate == nil
    }
    
    static public func shouldShow21DaySurvey(state: CTFReduxState) -> Bool {
        
        guard let baselineDate = state.baselineCompletedDate else {
            return false
        }
        
        //show am survey if the following are true
        //1) at least k21DayInterval since baseline has been completed
        //2) 21 day survey has not been completed
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        
        //1
        if timeSinceBaseline <= k21DaySurveyDelayInterval {
            return false
        }
        
        //2
        return state.day21CompletionDate == nil
        
    }
    
    static public func shouldShowMorningSurvey(state: CTFReduxState) -> Bool {
        
        //show am survey if the following are true
        //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
        //2) we are in the time range that the survey should be shown
        //3) survey has not yet been completed today
        
        //1
        guard let baselineDate = state.baselineCompletedDate else {
            return false
        }
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        guard timeSinceBaseline > CTFActionCreators.kDailySurveyDelaySinceBaselineTimeInterval else {
            return false
        }
        
        //2
        guard let morningSurveyTimeComponents = state.morningSurveyTimeComponents,
            let todaysMorningSurveyTime = CTFActionCreators.combineDateWithDateComponents(date: Date(), timeComponents: morningSurveyTimeComponents as NSDateComponents) else {
                return false
        }
 
        let lowerDate = Date(timeIntervalSinceNow: -1.0 * CTFActionCreators.kDailySurveyTimeAfterInterval)
        let upperDate = Date(timeIntervalSinceNow: CTFActionCreators.kDailySurveyTimeBeforeInterval)
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
    
    static public func shouldShowEveningSurvey(state: CTFReduxState) -> Bool {
        
        //show am survey if the following are true
        //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
        //2) we are in the time range that the survey should be shown
        //3) survey has not yet been completed today
        
        //1
        guard let baselineDate = state.baselineCompletedDate else {
            return false
        }
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        guard timeSinceBaseline > CTFActionCreators.kDailySurveyDelaySinceBaselineTimeInterval else {
            return false
        }
        
        //2
        guard let eveningSurveyTimeComponents = state.eveningSurveyTimeComponents,
            let todaysEveningSurveyTime = CTFActionCreators.combineDateWithDateComponents(date: Date(), timeComponents: eveningSurveyTimeComponents as NSDateComponents) else {
                return false
        }
        
        let lowerDate = Date(timeIntervalSinceNow: -1.0 * CTFActionCreators.kDailySurveyTimeAfterInterval)
        let upperDate = Date(timeIntervalSinceNow: CTFActionCreators.kDailySurveyTimeBeforeInterval)
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
            (newState.lastEveningCompletionDate != oldState.lastEveningCompletionDate)
    }

    static func getValueInExtensibleStorage(state: CTFReduxState, key: String) -> NSSecureCoding? {
        return state.extensibleStorage[key] as? NSSecureCoding
    }
}


