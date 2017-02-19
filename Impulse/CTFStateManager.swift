//
//  CTFStateManager.swift
//  Impulse
//
//  Created by James Kizer on 11/18/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import BridgeSDK

class CTFStateManager: NSObject, RSTBStateHelper, CTFAppStateProtocol {

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
    static let k21DayNotificationText: String = "Hey, it's time to take your 21 day survey!"
    
    
    public var isLoggedIn: Bool = false
    public var isLoaded: Bool = false
    
    
    
    override init() {
        super.init()
        //check for firstRun
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            self.setNotificationsBasedOnKeychainState()
            //            self.clearKeychain()
        }
    }
    
    static let defaultManager = CTFStateManager()
    
    public func clearState() {
        CTFKeychainHelpers.clearKeychain()
    }
    
    func dateComponents(forDate date: Date) -> DateComponents {
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let calendar = Locale.current.calendar
        // *** Get components from date ***
        return calendar.dateComponents(unitFlags, from: date)
    }
    
    func combineDateWithDateComponents(date: Date, timeComponents: NSDateComponents) -> Date? {
        
        // *** define calendar components to use as well Timezone to UTC ***
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let calendar = Locale.current.calendar
        // *** Get components from date ***
        var dateComponents = self.dateComponents(forDate: date)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        print("Components : \(dateComponents)")
        
        let returnDate = calendar.date(from: dateComponents)
        
        return returnDate != nil ? returnDate! : nil
    }
    
    
    private func cancelNotification(withIdentifier identifierToCancel: String) {
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
    
    private func cancelAllNotifications() {
        CTFStateManager.NotificationIdentifiers.forEach({self.cancelNotification(withIdentifier: $0)})
    }
    
    private func setNotification(forIdentifier: String, initialFireDate: Date, text: String) {
        let notification = UILocalNotification()
        notification.userInfo = ["identifier": forIdentifier]
        notification.fireDate = initialFireDate
        notification.repeatInterval = NSCalendar.Unit.day
        notification.alertBody = text
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    private func resetMorningNotification() {
        //morning notification
        //cancel notification if exists
        self.cancelNotification(withIdentifier: CTFStateManager.kMorningNotificationIdentifer)
        self.cancelNotification(withIdentifier: CTFStateManager.kMorningNotificationIdentifer2nd)
        //Set notification
        
        //if we have completed
        if let dateComponents = CTFKeychainHelpers.getKeychainObject(kMorningSurveyTime) as? NSDateComponents,
            let lastCompletion = CTFKeychainHelpers.getKeychainObject(kLastMorningSurveyCompleted) as? Date,
            let fireDate = self.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
            self.setNotification(forIdentifier: CTFStateManager.kMorningNotificationIdentifer, initialFireDate: fireDate, text: CTFStateManager.kMorningNotificationText)
            //set second notification
            self.setNotification(forIdentifier: CTFStateManager.kMorningNotificationIdentifer2nd, initialFireDate: fireDate.addingTimeInterval(kSecondaryNotificationDelay), text: CTFStateManager.kMorningNotificationText)
        }
    }
    
    private func resetEveningNotification() {
        //evening notification
        //cancel notification if exists
        self.cancelNotification(withIdentifier: CTFStateManager.kEveningNotificationIdentifer)
        self.cancelNotification(withIdentifier: CTFStateManager.kEveningNotificationIdentifer2nd)
        //Set notification
        if let dateComponents = CTFKeychainHelpers.getKeychainObject(kEveningSurveyTime) as? NSDateComponents,
            let lastCompletion = CTFKeychainHelpers.getKeychainObject(kLastEveningSurveyCompleted) as? Date,
            let fireDate = self.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
            self.setNotification(forIdentifier: CTFStateManager.kEveningNotificationIdentifer, initialFireDate: fireDate, text: CTFStateManager.kEveningNotificationText)
            //set second notification
            self.setNotification(forIdentifier: CTFStateManager.kEveningNotificationIdentifer2nd, initialFireDate: fireDate.addingTimeInterval(kSecondaryNotificationDelay), text: CTFStateManager.kEveningNotificationText)
        }
    }
    
    private func reset21DayNotification() {
        //21 day notification
        //cancel notification if exists
        self.cancelNotification(withIdentifier: CTFStateManager.k21DayNotificationIdentifier)
        self.cancelNotification(withIdentifier: CTFStateManager.k21DayNotificationIdentifier2nd)
        
        //Set notification
        if let baselineDate = CTFKeychainHelpers.getKeychainObject(kBaselineSurveyCompleted) as? Date {
            self.schedule21DayNotification(baselineDate)
        }
    }
    
    private func setNotificationsBasedOnKeychainState() {
        //note that we may only wannt to do this if the 21 day has not yet been completed
        self.resetMorningNotification()
        self.resetEveningNotification()
        self.reset21DayNotification()
    }
    
    
    //this should return the next notification date based on:
    //the latest completion date AND
    //the time of day that the user has chosen to take their survey
    private func getNotificationFireDate(timeComponents: NSDateComponents, latestCompletion: Date?) -> Date? {
        
        guard let baseDate: Date = {
            if let latestCompletion = latestCompletion,
                latestCompletion.isToday {
                let tomorrow = Date().addingNumberOfDays(1)
                return self.combineDateWithDateComponents(date: tomorrow, timeComponents: timeComponents)
            }
            else {
                return self.combineDateWithDateComponents(date: Date(), timeComponents: timeComponents)
            }
            }() else {
                return nil
        }
        
        //select window around baseDate
        let fromDate = baseDate.addingTimeInterval(-1.0 * kDailySurveyNotificationWindowBeforeInterval)
        let toDate = baseDate.addingTimeInterval(kDailySurveyNotificationWindowAfterInterval)
        
        return Date.RandomDateBetween(from: fromDate, to: toDate)
        
    }

    public func setMorningSurveyTime(_ dateComponents: DateComponents) {
            
        print("morning date components: \(dateComponents)")
        
        //save morning survey time - note that we will only display morning survey +- 1 hr from this time
        CTFKeychainHelpers.setKeychainObject(dateComponents as NSDateComponents, forKey: kMorningSurveyTime)
        
        //set notifications
        //simple case, repeating notification for next 21 days at this time
        //Talk to Fred about this
        
        //cancel notification if exists
        self.cancelNotification(withIdentifier: CTFStateManager.kMorningNotificationIdentifer)
        self.cancelNotification(withIdentifier: CTFStateManager.kMorningNotificationIdentifer2nd)
        
        //Set notification
        //initial fire date is today's date + time components, provided
        let lastCompletion: Date? = CTFKeychainHelpers.getKeychainObject(kLastMorningSurveyCompleted) as? Date
        
        if let fireDate = self.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
            self.setNotification(forIdentifier: CTFStateManager.kMorningNotificationIdentifer, initialFireDate: fireDate, text: CTFStateManager.kMorningNotificationText)
            //set second notification
            self.setNotification(forIdentifier: CTFStateManager.kMorningNotificationIdentifer2nd, initialFireDate: fireDate.addingTimeInterval(kSecondaryNotificationDelay), text: CTFStateManager.kMorningNotificationText)
        }
    }
    
    public func getMorningSurveyTime() -> DateComponents? {
        return CTFKeychainHelpers.getKeychainObject(kMorningSurveyTime) as? DateComponents
    }
    
    
    
    public func setEveningSurveyTime(_ dateComponents: DateComponents) {
            
        print("evening date components: \(dateComponents)")
        
        //save morning survey time - note that we will only display morning survey +- 1 hr from this time
        CTFKeychainHelpers.setKeychainObject(dateComponents as NSDateComponents, forKey: kEveningSurveyTime)
        
        //set notifications
        //simple case, repeating notification for next 21 days at this time
        //Talk to Fred about this
        
        //cancel notification if exists
        self.cancelNotification(withIdentifier: CTFStateManager.kEveningNotificationIdentifer)
        self.cancelNotification(withIdentifier: CTFStateManager.kEveningNotificationIdentifer2nd)
        
        //Set notification
        let lastCompletion: Date? = CTFKeychainHelpers.getKeychainObject(kLastEveningSurveyCompleted) as? Date
        
        if let fireDate = self.getNotificationFireDate(timeComponents: dateComponents as NSDateComponents, latestCompletion: lastCompletion) {
            self.setNotification(forIdentifier: CTFStateManager.kEveningNotificationIdentifer, initialFireDate: fireDate, text: CTFStateManager.kEveningNotificationText)
            //set second notification
            self.setNotification(forIdentifier: CTFStateManager.kEveningNotificationIdentifer2nd, initialFireDate: fireDate.addingTimeInterval(kSecondaryNotificationDelay), text: CTFStateManager.kEveningNotificationText)
        }

    }
    
    public func getEveningSurveyTime() -> DateComponents? {
        return CTFKeychainHelpers.getKeychainObject(kEveningSurveyTime) as? DateComponents
    }

    public func schedule21DayNotification(_ from: Date) {
        //cancel notification if exists
        self.cancelNotification(withIdentifier: CTFStateManager.k21DayNotificationIdentifier)
        self.cancelNotification(withIdentifier: CTFStateManager.k21DayNotificationIdentifier2nd)
        
        //Set notification
        let fireDate = Date(timeInterval: k21DaySurveyDelayInterval, since: from)
        self.setNotification(forIdentifier: CTFStateManager.k21DayNotificationIdentifier, initialFireDate: fireDate, text: CTFStateManager.k21DayNotificationText)
        //set second notification
        self.setNotification(forIdentifier: CTFStateManager.k21DayNotificationIdentifier2nd, initialFireDate: fireDate.addingTimeInterval(kSecondaryNotificationDelay), text: CTFStateManager.k21DayNotificationText)
    }
    
    public func getBaselineCompletionDate() -> Date? {
        return CTFKeychainHelpers.getKeychainObject(kBaselineSurveyCompleted) as? Date
    }

    
    //MARK: survey completion logic
    
    
    public func markBaselineSurveyAsCompleted(completedDate: Date) {
        CTFKeychainHelpers.setKeychainObject(completedDate as NSDate, forKey: kBaselineSurveyCompleted)
        
        //ask for permissions for notifications
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        //2) set 21 day notification
        CTFStateManager.defaultManager.schedule21DayNotification(completedDate)
    }
    
    public func markMorningSurveyCompleted(completedDate: Date) {
        
        CTFKeychainHelpers.setKeychainObject(completedDate as NSDate, forKey: kLastMorningSurveyCompleted)
        
        //2) cancel previous notification and set new one
        self.resetMorningNotification()
    }
    
    public func markEveningSurveyCompleted(completedDate: Date) {
        CTFKeychainHelpers.setKeychainObject(completedDate as NSDate, forKey: kLastEveningSurveyCompleted)
        
        //2) cancel previous notification and set new one
        self.resetEveningNotification()
    }
    
    public func mark21DaySurveyCompleted(completedDate: Date) {
        
        CTFKeychainHelpers.setKeychainObject(completedDate as NSDate, forKey: k21DaySurveyCompleted)
        
        self.cancelAllNotifications()
        
    }
    
    public func markTrialActivity(guid: String, completed: Bool) {
        
        //get completed trial activities
        let completedTrialActivities: [String] = CTFKeychainHelpers.getKeychainObject(kCompletedTrialActivities) as? [String] ?? []
        let newCompletedTrialActivities: [String] = completedTrialActivities + [guid]
        CTFKeychainHelpers.setKeychainObject(newCompletedTrialActivities as NSArray, forKey: kCompletedTrialActivities)
        
    }
    
    
    

    //MARK: presentation logic
    
    public var isBaselineCompleted: Bool {
        let baselineCompletedDate = CTFKeychainHelpers.getKeychainObject(kBaselineSurveyCompleted) as? NSDate
        return baselineCompletedDate != nil
    }
    
    public func shouldShowBaselineSurvey() -> Bool {
        return !self.isBaselineCompleted
    }
    
    public func isTrialActivityCompleted(guid: String) -> Bool {
        guard let completedTrialActivities: [String] = CTFKeychainHelpers.getKeychainObject(kCompletedTrialActivities) as? [String] else {
            return false
        }
        
        return completedTrialActivities.contains(guid)
    }
    
    public func shouldShow21DaySurvey() -> Bool {
        
        let baselineCompletedDate = CTFKeychainHelpers.getKeychainObject(kBaselineSurveyCompleted) as? NSDate
        
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
        return CTFKeychainHelpers.getKeychainObject(k21DaySurveyCompleted) == nil
        
    }
    
    public func shouldShowMorningSurvey() -> Bool {
        
        let baselineCompletedDate = CTFKeychainHelpers.getKeychainObject(kBaselineSurveyCompleted) as? NSDate
        
        //show am survey if the following are true
        //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
        //2) we are in the time range that the survey should be shown
        //3) survey has not yet been completed today
        
        //1
        guard let baselineDate = baselineCompletedDate else {
            return false
        }
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        guard timeSinceBaseline > kDailySurveyDelaySinceBaselineTimeInterval else {
            return false
        }
        
        //2
        guard let morningSurveyTimeComponents = CTFKeychainHelpers.getKeychainObject(kMorningSurveyTime) as? NSDateComponents,
            let todaysMorningSurveyTime = self.combineDateWithDateComponents(date: Date(), timeComponents: morningSurveyTimeComponents) else {
                return false
        }
        
        print(Date())
        
        let lowerDate = Date(timeIntervalSinceNow: -1.0 * kDailySurveyTimeAfterInterval)
        let upperDate = Date(timeIntervalSinceNow: kDailySurveyTimeBeforeInterval)
        let dateRange = Range(uncheckedBounds: (lower: lowerDate, upper: upperDate))
        if !dateRange.contains(todaysMorningSurveyTime as Date) {
            return false
        }
        
        //3 (note: if never taken, automatic true)
        //if it has been taken, it will be in today's range
        if let latestSurveyTime = CTFKeychainHelpers.getKeychainObject(kLastMorningSurveyCompleted) as? NSDate {
            return !dateRange.contains(latestSurveyTime as Date)
        }
        else {
            return true
        }
    }
    
    public func shouldShowEveningSurvey() -> Bool {
        
        let baselineCompletedDate = CTFKeychainHelpers.getKeychainObject(kBaselineSurveyCompleted) as? NSDate
        
        //show am survey if the following are true
        //1) Baseline has been completed at least kDailySurveyDelaySinceBaselineTimeInterval ago
        //2) we are in the time range that the survey should be shown
        //3) survey has not yet been completed today
        
        //1
        guard let baselineDate = baselineCompletedDate else {
            return false
        }
        
        let timeSinceBaseline = NSDate().timeIntervalSince(baselineDate as Date)
        guard timeSinceBaseline > kDailySurveyDelaySinceBaselineTimeInterval else {
            return false
        }
        
        //2
        guard let eveningSurveyTimeComponents = CTFKeychainHelpers.getKeychainObject(kEveningSurveyTime) as? NSDateComponents,
            let todaysEveningSurveyTime = self.combineDateWithDateComponents(date: Date(), timeComponents: eveningSurveyTimeComponents)  else {
                return false
        }
        
        print(Date())
        
        let lowerDate = Date(timeIntervalSinceNow: -1.0 * kDailySurveyTimeAfterInterval)
        let upperDate = Date(timeIntervalSinceNow: kDailySurveyTimeBeforeInterval)
        let dateRange = Range(uncheckedBounds: (lower: lowerDate, upper: upperDate))
        if !dateRange.contains(todaysEveningSurveyTime as Date) {
            return false
        }
        
        //3 (note: if never taken, automatic true)
        //if it has been taken, it will be in today's range
        if let latestSurveyTime = CTFKeychainHelpers.getKeychainObject(kLastEveningSurveyCompleted) as? NSDate {
            return !dateRange.contains(latestSurveyTime as Date)
        }
        else {
            return true
        }
    }
    
    public func shouldShowTrialActivities() -> Bool {
        
        guard self.isBaselineCompleted else {
            return false
        }
        
        guard let showActivities = CTFKeychainHelpers.getKeychainObject(kTrialActivitiesEnabled) as? Bool else {
            return true
        }
        return showActivities
    }
    
    public func setShowTrials(showTrials: Bool) {
        //set keychain value
        CTFKeychainHelpers.setKeychainObject(showTrials as NSSecureCoding, forKey: kTrialActivitiesEnabled)
        
    }
    
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        if let val = value {
            CTFKeychainHelpers.setKeychainObject(val, forKey: forKey)
        }
        else {
            CTFKeychainHelpers.removeKeychainObject(forKey: forKey)
        }
    }
    
    public func valueInState(forKey: String) -> NSSecureCoding? {
        return CTFKeychainHelpers.getKeychainObject(forKey)
    }

}
