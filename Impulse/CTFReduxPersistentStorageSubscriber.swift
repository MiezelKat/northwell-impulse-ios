//
//  CTFReduxPersistentStorageSubscriber.swift
//  Impulse
//
//  Created by James Kizer on 2/20/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

class ObservableValue<T: Equatable>: NSObject {
    
    typealias ObservationClosure = (T?) -> ()
    
    let _closure: ObservationClosure?
    var _value: T?
    
    func get() -> T? {
        return _value
    }
    
    func set(value: T?) {
        if value != _value {
            self._value = value
            self._closure?(value)
        }
    }
    
    init(initialValue: T?, observationClosure: ObservationClosure?) {
        self._closure = observationClosure
        super.init()
        
        self._value = initialValue
        
    }
}

class PersistedValue<T: Equatable>: ObservableValue<T> {
    
    init(key: String) {
        
        let observationClosure: ObservationClosure = { value in
            CTFStateManager.defaultManager.setValueInState(value: value as? NSSecureCoding, forKey: key)
        }
        
        super.init(
            initialValue: CTFStateManager.defaultManager.valueInState(forKey: key) as? T,
            observationClosure: observationClosure
        )

    }
}

class CTFReduxPersistentStorageSubscriber: NSObject, StoreSubscriber {
    
    static let kLastCompletedTaskIdentifier = "lastCompletedTaskIdentifier"
    
    
    static let kBaselineSurveyCompleted: String = "BaselineSurveyCompleted"
    static let kDay21NotificationFireDate: String = "day21NotificationFireDate"
    static let kDay212ndNotificationFireDate: String = "day212ndNotificationFireDate"
    static let kMorningNotificationFireDate: String = "morningNotificationFireDate"
    static let kMorning2ndNotificationFireDate: String = "morning2ndNotificationFireDate"
    static let kEveningNotificationFireDate: String = "eveningNotificationFireDate"
    static let kEvening2ndNotificationFireDate: String = "evening2ndNotificationFireDate"
    static let kEnable2ndReminderNotifications: String = "enable2ndReminderNotifications"
    
    
    
    
    static let kMorningSurveyTime: String = "MorningSurveyTime"
    static let kEveningSurveyTime: String = "EveningSurveyTime"
    static let kLastMorningSurveyCompleted: String = "LastMorningSurveyCompleted"
    static let kLastEveningSurveyCompleted: String = "LastEveningSurveycompleted"
    static let k21DaySurveyCompleted: String = "21DaySurveyCompleted"
    static let kBaselineBehaviorResults: String = "BaselineBehaviorResults"
    static let kTrialActivitiesEnabled: String = "TrialActivitiesEnabled"
    static let kCompletedTrialActivities: String = "CompeltedTrialActivities"
    
    let lastCompletedTaskIdentifier = PersistedValue<String>(key: CTFReduxPersistentStorageSubscriber.kLastCompletedTaskIdentifier)
    
    let baselineCompletedDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kBaselineSurveyCompleted)
    
    let day21NotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kDay21NotificationFireDate)
    let day212ndNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kDay212ndNotificationFireDate)
    
    let morningNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kMorningNotificationFireDate)
    let morning2ndNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kMorning2ndNotificationFireDate)
    
    let eveningNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kEveningNotificationFireDate)
    let evening2ndNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kEvening2ndNotificationFireDate)
    
    let enable2ndReminderNotifications = PersistedValue<Bool>(key: CTFReduxPersistentStorageSubscriber.kEnable2ndReminderNotifications)
    
    
    func loadState() -> CTFReduxStore {
        return CTFReduxStore(
            activityQueue: [],
            resultsQueue: [],
            lastCompletedTaskIdentifier: self.lastCompletedTaskIdentifier.get(),
            baselineCompletedDate: self.baselineCompletedDate.get(),
            day21NotificationFireDate: self.day21NotificationFireDate.get(),
            day212ndNotificationFireDate: self.day212ndNotificationFireDate.get(),
            
            morningNotificationFireDate: self.morningNotificationFireDate.get(),
            morning2ndNotificationFireDate: self.morning2ndNotificationFireDate.get(),
            eveningNotificationFireDate: self.eveningNotificationFireDate.get(),
            evening2ndNotificationFireDate: self.evening2ndNotificationFireDate.get(),
            
            enable2ndReminderNotifications: self.enable2ndReminderNotifications.get() ?? true
        )
    }
    
    static let sharedInstance = CTFReduxPersistentStorageSubscriber()
    
    private override init() {
        super.init()
        
    }
    
    func newState(state: CTFReduxStore) {
        
        self.lastCompletedTaskIdentifier.set(value: state.lastCompletedTaskIdentifier)
        self.baselineCompletedDate.set(value: state.baselineCompletedDate)
        
        self.day21NotificationFireDate.set(value: state.day21NotificationFireDate)
        self.day212ndNotificationFireDate.set(value: state.day212ndNotificationFireDate)
        
        self.morningNotificationFireDate.set(value: state.morningNotificationFireDate)
        self.morning2ndNotificationFireDate.set(value: state.morning2ndNotificationFireDate)
        
        self.eveningNotificationFireDate.set(value: state.eveningNotificationFireDate)
        self.evening2ndNotificationFireDate.set(value: state.evening2ndNotificationFireDate)
        
        self.enable2ndReminderNotifications.set(value: state.enable2ndReminderNotifications)
        
    }
    
}
