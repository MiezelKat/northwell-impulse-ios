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
    
    let key: String
    
    init(key: String) {
        self.key = key
        
        let observationClosure: ObservationClosure = { value in
            let secureCodingValue = value as? NSSecureCoding
            debugPrint(secureCodingValue)
            CTFStateManager.defaultManager.setValueInState(value: secureCodingValue, forKey: key)
        }
        
        super.init(
            initialValue: CTFStateManager.defaultManager.valueInState(forKey: key) as? T,
            observationClosure: observationClosure
        )

    }
    
    func delete() {
        CTFStateManager.defaultManager.setValueInState(value: nil, forKey: self.key)
    }
}

class PersistedValueMap: NSObject {
    
    let keyArrayKey: String
    let valueKeyComputeFunction: (String) -> (String)
    var map: [String: PersistedValue<NSObject>]
    var keys: PersistedValue<NSArray>
    
    init(key: String) {
        self.keyArrayKey = [key, "arrayKey"].joined(separator: ".")
        
        self.valueKeyComputeFunction = { valueKey in
            return [key, valueKey].joined(separator: ".")
        }
        self.keys = PersistedValue<NSArray>(key: self.keyArrayKey)
        
        if self.keys.get() == nil {
            self.keys.set(value: [String]() as NSArray)
        }
        
        self.map = [:]
        
        super.init()
        
        if let keys = self.keys.get() as? [String] {
            keys.forEach({ (key) in
                let valueKey = self.valueKeyComputeFunction(key)
                self.map[key] = PersistedValue<NSObject>(key: valueKey)
            })
        }
        
    }
    
    
    
    private subscript(key: String) -> NSObject? {
        
        get {
            
            if let persistedValue = self.map[key] {
                return persistedValue.get()
            }
            else {
                return nil
            }
        }
        
        set(newValue) {
            
            //check to see if key exists
            if let persistedValue = self.map[key] {
                
                assert(self.keys.get()!.contains(key), "PersistedValueMapError: Keys and Map Inconsistent")
                
                persistedValue.set(value: newValue)
                
                if newValue == nil {
                    persistedValue.delete()
                    self.map.removeValue(forKey: key)
                    let newKeys = (self.keys.get() as! [String]).filter({ (k) -> Bool in
                        return k != key
                    })
                    
                    self.keys.set(value: newKeys as NSArray)
                }
                
            }
            else {
                //key does not exist,
                
                if newValue != nil {
                    //add value to map
                    let newValueKey = self.valueKeyComputeFunction(key)
                    let newPersistedValue = PersistedValue<NSObject>(key: newValueKey)
                    newPersistedValue.set(value: newValue)
                    self.map[key] = newPersistedValue
                    let newKeys = (self.keys.get() as! [String]) + [key]
                    self.keys.set(value: newKeys as NSArray)
                }
            }
            
        }
    }

    func get() -> [String: NSObject] {
        
        
        let keys = self.keys.get() as! [String]
        var dict = [String: NSObject]()
        keys.forEach({ (key) in
            dict[key] = self.map[key]?.get()
        })
        
        return dict
    }
    
    func set(map: [String: NSObject]) {
    
        map.keys.forEach { (key) in
            self[key] = map[key]
        }
        
        //do set subtraction to potentially remove values
        let extraKeys: Set<String> = Set(self.map.keys).subtracting(Set(map.keys))
        extraKeys.forEach { (key) in
            self[key] = nil
        }
        
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
    
    static let kExtensibleStorage: String = "ExtensibleStorage"
    
    static let kShouldShowTrialActivities: String = "ShouldShowTrialActivities"
    
    let lastCompletedTaskIdentifier = PersistedValue<String>(key: CTFReduxPersistentStorageSubscriber.kLastCompletedTaskIdentifier)
    
    let baselineCompletedDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kBaselineSurveyCompleted)
    let lastMorningCompletionDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kLastMorningSurveyCompleted)
    let lastEveningCompletionDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kLastEveningSurveyCompleted)
    let day21CompletionDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.k21DaySurveyCompleted)
    
    let morningSurveyTimeComponents = PersistedValue<DateComponents>(key: CTFReduxPersistentStorageSubscriber.kMorningSurveyTime)
    let eveningSurveyTimeComponents = PersistedValue<DateComponents>(key: CTFReduxPersistentStorageSubscriber.kEveningSurveyTime)
    
    let day21NotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kDay21NotificationFireDate)
    let day212ndNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kDay212ndNotificationFireDate)
    
    let morningNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kMorningNotificationFireDate)
    let morning2ndNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kMorning2ndNotificationFireDate)
    
    let eveningNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kEveningNotificationFireDate)
    let evening2ndNotificationFireDate = PersistedValue<Date>(key: CTFReduxPersistentStorageSubscriber.kEvening2ndNotificationFireDate)
    
    let enable2ndReminderNotifications = PersistedValue<Bool>(key: CTFReduxPersistentStorageSubscriber.kEnable2ndReminderNotifications)
    
    let extensibleStorage = PersistedValueMap(key: CTFReduxPersistentStorageSubscriber.kExtensibleStorage)
    
    let shouldShowTrialActivities = PersistedValue<Bool>(key: CTFReduxPersistentStorageSubscriber.kShouldShowTrialActivities)
    
    
    func loadState() -> CTFReduxState {
        return CTFReduxState(
            activityQueue: [],
            resultsQueue: [],
            lastCompletedTaskIdentifier: self.lastCompletedTaskIdentifier.get(),
            baselineCompletedDate: self.baselineCompletedDate.get(),
            lastMorningCompletionDate: self.lastMorningCompletionDate.get(),
            lastEveningCompletionDate: self.lastEveningCompletionDate.get(),
            day21CompletionDate: self.day21CompletionDate.get(),
            morningSurveyTimeComponents: self.morningSurveyTimeComponents.get(),
            eveningSurveyTimeComponents: self.eveningSurveyTimeComponents.get(),
            day21NotificationFireDate: self.day21NotificationFireDate.get(),
            day212ndNotificationFireDate: self.day212ndNotificationFireDate.get(),
            morningNotificationFireDate: self.morningNotificationFireDate.get(),
            morning2ndNotificationFireDate: self.morning2ndNotificationFireDate.get(),
            eveningNotificationFireDate: self.eveningNotificationFireDate.get(),
            evening2ndNotificationFireDate: self.evening2ndNotificationFireDate.get(),
            enable2ndReminderNotifications: self.enable2ndReminderNotifications.get() ?? true,
            extensibleStorage: self.extensibleStorage.get(),
            shouldShowTrialActivities: self.shouldShowTrialActivities.get() ?? false
        )
    }
    
//    static private let staticQueue = DispatchQueue(label: "CTFReduxPersistentStorageSubscriberStaticQueue")
//    
//    static private var _sharedInstance: CTFReduxPersistentStorageSubscriber?
//    
//    
//    public static var sharedInstance: CTFReduxPersistentStorageSubscriber {
//        return staticQueue.sync {
//            if _sharedInstance == nil {
//                _sharedInstance = CTFReduxPersistentStorageSubscriber()
//            }
//            return _sharedInstance!
//        }
//    }
//    
//    public static func clear() {
//        return staticQueue.sync {
//            CTFStateManager.defaultManager.clearState()
//        }
//    }
//    
//    private override init() {
//        super.init()
//        
//    }
    
    func newState(state: CTFReduxState) {
        
        self.lastCompletedTaskIdentifier.set(value: state.lastCompletedTaskIdentifier)
        self.baselineCompletedDate.set(value: state.baselineCompletedDate)
        self.lastMorningCompletionDate.set(value: state.lastMorningCompletionDate)
        self.lastEveningCompletionDate.set(value: state.lastEveningCompletionDate)
        self.day21CompletionDate.set(value: state.day21CompletionDate)
        
        self.morningSurveyTimeComponents.set(value: state.morningSurveyTimeComponents)
        self.eveningSurveyTimeComponents.set(value: state.eveningSurveyTimeComponents)
        
        self.day21NotificationFireDate.set(value: state.day21NotificationFireDate)
        self.day212ndNotificationFireDate.set(value: state.day212ndNotificationFireDate)
        
        self.morningNotificationFireDate.set(value: state.morningNotificationFireDate)
        self.morning2ndNotificationFireDate.set(value: state.morning2ndNotificationFireDate)
        
        self.eveningNotificationFireDate.set(value: state.eveningNotificationFireDate)
        self.evening2ndNotificationFireDate.set(value: state.evening2ndNotificationFireDate)
        
        self.enable2ndReminderNotifications.set(value: state.enable2ndReminderNotifications)
        
        self.extensibleStorage.set(map: state.extensibleStorage)
        
        self.shouldShowTrialActivities.set(value: state.shouldShowTrialActivities)
        
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }
    
}
