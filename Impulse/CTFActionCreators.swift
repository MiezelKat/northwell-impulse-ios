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
    
    static func handleBaselineSurvey(_ result: ORKTaskResult) {
        
        let markBaselineAction = MarkBaselineSurveyCompletedAction(completedDate: result.endDate)
        CTFReduxStoreManager.mainStore.dispatch(markBaselineAction)
        
        let initialFireDate = Date(timeInterval: CTFActionCreators.k21DaySurveyDelayInterval, since: result.endDate)
        let secondaryFireDate = initialFireDate.addingTimeInterval(CTFActionCreators.kSecondaryNotificationDelay)
        let day21NotificationAction = Set21DayNotificationAction(
            initialFireDate: initialFireDate,
            secondaryFireDate: secondaryFireDate)
        
        CTFReduxStoreManager.mainStore.dispatch(day21NotificationAction)
        
        
    }

}
