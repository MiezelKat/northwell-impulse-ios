//
//  CTFStudyConstants.swift
//  Impulse
//
//  Created by James Kizer on 2/23/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit

class CTFStudyConstants {
    
    static let k1MinuteInterval: TimeInterval = 60.0
    static let k1HourInterval: TimeInterval = CTFStudyConstants.k1MinuteInterval * 60.0
    static let k1DayInterval: TimeInterval = 24.0 * CTFStudyConstants.k1HourInterval
    
    static let kNumberOfDaysForFinalSurvey = 7
    static let k21DaySurveyDelayInterval: TimeInterval = Double(CTFStudyConstants.kNumberOfDaysForFinalSurvey) * CTFStudyConstants.k1DayInterval
    
    static let kDailySurveyNotificationWindowBeforeInterval: TimeInterval = 0.0
    static let kDailySurveyNotificationWindowAfterInterval: TimeInterval = 30.0 * CTFStudyConstants.k1MinuteInterval
    static let kDailySurveyTimeBeforeInterval: TimeInterval = 2.0 * CTFStudyConstants.k1HourInterval
    static let kDailySurveyTimeAfterInterval: TimeInterval = 6.0 * CTFStudyConstants.k1HourInterval
    static let kDailySurveyDelaySinceBaselineTimeInterval: TimeInterval = 0.0
    
    static let kSecondaryNotificationDelay: TimeInterval = 2.0 * CTFStudyConstants.k1HourInterval
    
    static let kMorningNotificationIdentifer: String = "MorningNotification"
    static let kMorningNotificationIdentifer2nd: String = "MorningNotification2nd"
    static let kEveningNotificationIdentifer: String = "EveningNotification"
    static let kEveningNotificationIdentifer2nd: String = "EveningNotification2nd"
    static let k21DayNotificationIdentifier: String = "21DayNotification"
    static let k21DayNotificationIdentifier2nd: String = "21DayNotification2nd"
    
    static let NotificationIdentifiers = [kMorningNotificationIdentifer, kMorningNotificationIdentifer2nd,
                                          kEveningNotificationIdentifer, kEveningNotificationIdentifer2nd,
                                          k21DayNotificationIdentifier, k21DayNotificationIdentifier2nd]
    
    static let kMorningNotificationText: String = "Hey, it's time to take your morning survey!"
    static let kEveningNotificationText: String = "Hey, it's time to take your evening survey!"
    static let k21DayNotificationText: String = "Hey, it's time to take your day 7 survey!"
    
    static let kSessionTokenKey: String = "SessionToken"
    static let kPasswordKey: String = "Password"
    static let kEmailKey: String = "Email"

    static let kBaselineBehaviorResults: String = "BaselineBehaviorResults"
}
