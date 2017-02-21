//
//  CTFReduxStore.swift
//  Impulse
//
//  Created by James Kizer on 2/20/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

struct CTFReduxStore: StateType {
    let activityQueue: [(UUID, CTFActivityRun)]
    let resultsQueue: [(UUID, CTFActivityRun, ORKTaskResult)]
    let lastCompletedTaskIdentifier: String?
    let baselineCompletedDate: Date?
    let day21NotificationFireDate: Date?
    let day212ndNotificationFireDate: Date?
    
    let morningNotificationFireDate: Date?
    let morning2ndNotificationFireDate: Date?
    
    let eveningNotificationFireDate: Date?
    let evening2ndNotificationFireDate: Date?
    
    let enable2ndReminderNotifications: Bool
    
    static func empty() -> CTFReduxStore {
        return CTFReduxStore(
            activityQueue: [],
            resultsQueue: [],
            lastCompletedTaskIdentifier: nil,
            baselineCompletedDate: nil,
            day21NotificationFireDate: nil,
            day212ndNotificationFireDate: nil,
            morningNotificationFireDate: nil,
            morning2ndNotificationFireDate: nil,
            eveningNotificationFireDate: nil,
            evening2ndNotificationFireDate: nil,
            enable2ndReminderNotifications: true
        )
    }
}
