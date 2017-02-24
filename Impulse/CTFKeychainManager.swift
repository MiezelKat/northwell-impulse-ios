//
//  CTFKeychainManager.swift
//  Impulse
//
//  Created by James Kizer on 11/9/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit
import BridgeSDK

class CTFKeychainManager: NSObject {
    static func setKeychainObject(_ object: NSSecureCoding, forKey key: String) {
        do {
            try ORKKeychainWrapper.setObject(object, forKey: key)
        } catch let error {
            assertionFailure("Got error \(error) when setting \(key)")
        }
    }
    
    static func removeKeychainObject(forKey key: String) {
        do {
            try ORKKeychainWrapper.removeObject(forKey: key)
        } catch let error {
            assertionFailure("Got error \(error) when setting \(key)")
        }
    }
    
    static func clearKeychain() {
        do {
            try ORKKeychainWrapper.resetKeychain()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func getKeychainObject(_ key: String) -> NSSecureCoding? {
        
        var error: NSError?
        let o = ORKKeychainWrapper.object(forKey: key, error: &error)
        if error == nil {
            return o
        }
        else {
            print("Got error \(error) when getting \(key). This may just be the key has not yet been set!!")
            return nil
        }
    }
    
    static public func setValueInState(value: NSSecureCoding?, forKey: String) {
        if let val = value {
            CTFKeychainManager.setKeychainObject(val, forKey: forKey)
        }
        else {
            CTFKeychainManager.removeKeychainObject(forKey: forKey)
        }
    }
    
    static public func valueInState(forKey: String) -> NSSecureCoding? {
        return CTFKeychainManager.getKeychainObject(forKey)
    }
}
