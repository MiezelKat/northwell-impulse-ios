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

class PersistedValue<T: Equatable>: NSObject {
    
    let _key: String
    var _value: T?

    func get() -> T? {
        return _value
    }
    
    func set(value: T?) {
        if value != _value {
            _value = value
            CTFStateManager.defaultManager.setValueInState(value: value as? NSSecureCoding, forKey: self._key)
        }
    }
    
    init(key: String) {
        self._key = key
        super.init()

        self._value = CTFStateManager.defaultManager.valueInState(forKey: key) as? T

    }
}

class CTFReduxPersistentStorageSubscriber: NSObject, StoreSubscriber {
    
    static let kLastCompletedTaskIdentifier = "lastCompletedTaskIdentifier"
    
    func loadState() -> CTFReduxStore {
        return CTFReduxStore(
            activityQueue: [],
            resultsQueue: [],
            lastCompletedTaskIdentifier: self.lastCompletedTaskIdentifier.get())
    }
    
    static let sharedInstance = CTFReduxPersistentStorageSubscriber()
    
    private override init() {
        super.init()
        
    }
    
    let lastCompletedTaskIdentifier = PersistedValue<String>(key: CTFReduxPersistentStorageSubscriber.kLastCompletedTaskIdentifier)
    
    func newState(state: CTFReduxStore) {
        
        self.lastCompletedTaskIdentifier.set(value: state.lastCompletedTaskIdentifier)
        
    }
    
}
