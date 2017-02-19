//
//  CTFKeychainHelpers.swift
//  Impulse
//
//  Created by James Kizer on 11/9/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

let kMorningSurveyTime: String = "MorningSurveyTime"
let kEveningSurveyTime: String = "EveningSurveyTime"
let kLastMorningSurveyCompleted: String = "LastMorningSurveyCompleted"
let kLastEveningSurveyCompleted: String = "LastEveningSurveycompleted"
let kBaselineSurveyCompleted: String = "BaselineSurveyCompleted"
let k21DaySurveyCompleted: String = "21DaySurveyCompleted"
let kBaselineBehaviorResults: String = "BaselineBehaviorResults"
let kTrialActivitiesEnabled: String = "TrialActivitiesEnabled"
let kCompletedTrialActivities: String = "CompeltedTrialActivities"

class CTFKeychainHelpers: NSObject {
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
}
