//
//  CTFNotificationSubscriber.swift
//  Impulse
//
//  Created by James Kizer on 2/21/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift

class CTFNotificationSubscriber: NSObject, StoreSubscriber {
    
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
    
    static let kMorningTaskIdentifier: String = "am_survey"
    static let kEveningTaskIdentifier: String = "pm_survey"
    static let k21DayTaskIdentifier: String = "21-day-assessment"
    
    
    let day21NotificationFireDate: ObservableValue<Date>
    let day212ndNotificationFireDate: ObservableValue<Date>
    
    let morningNotificationFireDate: ObservableValue<Date>
    let morning2ndNotificationFireDate: ObservableValue<Date>
    
    let eveningNotificationFireDate: ObservableValue<Date>
    let evening2ndNotificationFireDate: ObservableValue<Date>
    
//    static private var _sharedInstance: CTFNotificationSubscriber?
//    
//    public static var sharedInstance: CTFNotificationSubscriber {
//        return _sharedInstance!
//    }
//    
//    public static func config(state: CTFReduxState) -> CTFNotificationSubscriber {
//        _sharedInstance = CTFNotificationSubscriber(state: state)
//        return _sharedInstance!
//    }
    
    private static func observationClosureGenerator(notificationIdentifier: String, text: String, taskIdentifier: String) -> (Date?) -> () {
        return { date in
            if let fireDate = date {
                
                CTFNotificationSubscriber.setNotification(
                    forIdentifier: notificationIdentifier,
                    initialFireDate: fireDate,
                    text: text,
                    taskIdentifier: taskIdentifier
                )
                
            }
            else {
                CTFNotificationSubscriber.cancelNotification(withIdentifier: notificationIdentifier)
            }
        }
    }
    
    override init() {
        
        self.day21NotificationFireDate = ObservableValue(
            initialValue: nil,
            observationClosure: CTFNotificationSubscriber.observationClosureGenerator(
                notificationIdentifier: CTFNotificationSubscriber.k21DayNotificationIdentifier,
                text: CTFNotificationSubscriber.k21DayNotificationText,
                taskIdentifier: CTFNotificationSubscriber.k21DayTaskIdentifier
        ))
        
        self.day212ndNotificationFireDate = ObservableValue(
            initialValue: nil,
            observationClosure: CTFNotificationSubscriber.observationClosureGenerator(
                notificationIdentifier: CTFNotificationSubscriber.k21DayNotificationIdentifier2nd,
                text: CTFNotificationSubscriber.k21DayNotificationText,
                taskIdentifier: CTFNotificationSubscriber.k21DayTaskIdentifier
        ))
        
        self.morningNotificationFireDate = ObservableValue(
            initialValue: nil,
            observationClosure: CTFNotificationSubscriber.observationClosureGenerator(
                notificationIdentifier: CTFNotificationSubscriber.kMorningNotificationIdentifer,
                text: CTFNotificationSubscriber.kMorningNotificationText,
                taskIdentifier: CTFNotificationSubscriber.kMorningTaskIdentifier
        ))
        
        self.morning2ndNotificationFireDate = ObservableValue(
            initialValue: nil,
            observationClosure: CTFNotificationSubscriber.observationClosureGenerator(
                notificationIdentifier: CTFNotificationSubscriber.kMorningNotificationIdentifer2nd,
                text: CTFNotificationSubscriber.kMorningNotificationText,
                taskIdentifier: CTFNotificationSubscriber.kMorningTaskIdentifier
        ))
        
        self.eveningNotificationFireDate = ObservableValue(
            initialValue: nil,
            observationClosure: CTFNotificationSubscriber.observationClosureGenerator(
                notificationIdentifier: CTFNotificationSubscriber.kEveningNotificationIdentifer,
                text: CTFNotificationSubscriber.kEveningNotificationText,
                taskIdentifier: CTFNotificationSubscriber.kEveningTaskIdentifier
        ))
        
        self.evening2ndNotificationFireDate = ObservableValue(
            initialValue: nil,
            observationClosure: CTFNotificationSubscriber.observationClosureGenerator(
                notificationIdentifier: CTFNotificationSubscriber.kEveningNotificationIdentifer2nd,
                text: CTFNotificationSubscriber.kEveningNotificationText,
                taskIdentifier: CTFNotificationSubscriber.kEveningTaskIdentifier
        ))
        
        super.init()
        
    }
    
    func newState(state: CTFReduxState) {
        
        self.day21NotificationFireDate.set(value: state.day21NotificationFireDate)
        self.day212ndNotificationFireDate.set(value: state.day212ndNotificationFireDate)
        
        self.morningNotificationFireDate.set(value: state.morningNotificationFireDate)
        self.morning2ndNotificationFireDate.set(value: state.morning2ndNotificationFireDate)
        
        self.eveningNotificationFireDate.set(value: state.eveningNotificationFireDate)
        self.evening2ndNotificationFireDate.set(value: state.evening2ndNotificationFireDate)
        
    }
    
    static private func setNotification(forIdentifier: String, initialFireDate: Date, text: String, taskIdentifier: String) {
        
        //always clear notification before setting
        cancelNotification(withIdentifier: forIdentifier)
        
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        let notification = UILocalNotification()
        notification.userInfo = ["identifier": forIdentifier, "taskIdentifier": taskIdentifier]
        notification.fireDate = initialFireDate
        notification.repeatInterval = NSCalendar.Unit.day
        notification.alertBody = text
        UIApplication.shared.scheduleLocalNotification(notification)
    }

    static private func cancelNotification(withIdentifier identifierToCancel: String) {
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
    
    public func cancelAllNotifications() {
        CTFNotificationSubscriber.NotificationIdentifiers.forEach({CTFNotificationSubscriber.cancelNotification(withIdentifier: $0)})
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }
}
