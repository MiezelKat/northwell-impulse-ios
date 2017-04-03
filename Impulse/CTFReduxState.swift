//
//  CTFReduxState.swift
//  Impulse
//
//  Created by James Kizer on 2/20/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

public struct CTFReduxState: StateType {
    
    let loaded: Bool
    let loggedIn: Bool
    let sessionToken: String?
    let email: String?
    let password: String?
    
    let groupLabel: String?
    
    let activityQueue: [(UUID, CTFActivityRun)]
    let resultsQueue: [(UUID, CTFActivityRun, ORKTaskResult)]
    let lastCompletedTaskIdentifier: String?
    
    let baselineCompletedDate: Date?
    let lastMorningCompletionDate: Date?
    let lastEveningCompletionDate: Date?
    let day21CompletionDate: Date?
    
    let morningSurveyTimeComponents: DateComponents?
    let eveningSurveyTimeComponents: DateComponents?
    
    let day21NotificationFireDate: Date?
    let day212ndNotificationFireDate: Date?
    
    let morningNotificationFireDate: Date?
    let morning2ndNotificationFireDate: Date?
    
    let eveningNotificationFireDate: Date?
    let evening2ndNotificationFireDate: Date?
    
    let enable2ndReminderNotifications: Bool
    
    let extensibleStorage: [String: NSObject]
    
    let shouldShowTrialActivities: Bool
    let debugMode: Bool
    
    static func empty() -> CTFReduxState {
        return CTFReduxState(
            loaded: false,
            loggedIn: false,
            sessionToken: nil,
            email: nil,
            password: nil,
            groupLabel: nil,
            activityQueue: [],
            resultsQueue: [],
            lastCompletedTaskIdentifier: nil,
            baselineCompletedDate: nil,
            lastMorningCompletionDate: nil,
            lastEveningCompletionDate: nil,
            day21CompletionDate: nil,
            morningSurveyTimeComponents: nil,
            eveningSurveyTimeComponents: nil,
            day21NotificationFireDate: nil,
            day212ndNotificationFireDate: nil,
            morningNotificationFireDate: nil,
            morning2ndNotificationFireDate: nil,
            eveningNotificationFireDate: nil,
            evening2ndNotificationFireDate: nil,
            enable2ndReminderNotifications: true,
            extensibleStorage: [:],
            shouldShowTrialActivities: false,
            debugMode: false
        )
    }
    
    
    //note the double optionals in the case of optionals!!
    static func newState(
        fromState: CTFReduxState,
        loaded: Bool? = nil,
        loggedIn: Bool? = nil,
        sessionToken: (String?)? = nil,
        email: (String?)? = nil,
        password: (String?)? = nil,
        groupLabel: (String?)? = nil,
        activityQueue: [(UUID, CTFActivityRun)]? = nil,
        resultsQueue: [(UUID, CTFActivityRun, ORKTaskResult)]? = nil,
        lastCompletedTaskIdentifier: (String?)? = nil,
        baselineCompletedDate: (Date?)? = nil,
        lastMorningCompletionDate: (Date?)? = nil,
        lastEveningCompletionDate: (Date?)? = nil,
        day21CompletionDate: (Date?)? = nil,
        morningSurveyTimeComponents: (DateComponents?)? = nil,
        eveningSurveyTimeComponents: (DateComponents?)? = nil,
        day21NotificationFireDate: (Date?)? = nil,
        day212ndNotificationFireDate: (Date?)? = nil,
        morningNotificationFireDate: (Date?)? = nil,
        morning2ndNotificationFireDate: (Date?)? = nil,
        eveningNotificationFireDate: (Date?)? = nil,
        evening2ndNotificationFireDate: (Date?)? = nil,
        enable2ndReminderNotifications: Bool? = nil,
        extensibleStorage: [String: NSObject]? = nil,
        shouldShowTrialActivities: Bool? = nil,
        debugMode: Bool? = nil
        ) -> CTFReduxState {
        return CTFReduxState(
            loaded: loaded ?? fromState.loaded,
            loggedIn: loggedIn ?? fromState.loggedIn,
            sessionToken: sessionToken ?? fromState.sessionToken,
            email: email ?? fromState.email,
            password: password ?? fromState.password,
            groupLabel: groupLabel ?? fromState.groupLabel,
            activityQueue: activityQueue ?? fromState.activityQueue,
            resultsQueue: resultsQueue ?? fromState.resultsQueue,
            lastCompletedTaskIdentifier: lastCompletedTaskIdentifier ?? fromState.lastCompletedTaskIdentifier,
            baselineCompletedDate: baselineCompletedDate ?? fromState.baselineCompletedDate,
            lastMorningCompletionDate: lastMorningCompletionDate ?? fromState.lastMorningCompletionDate,
            lastEveningCompletionDate: lastEveningCompletionDate ?? fromState.lastEveningCompletionDate,
            day21CompletionDate: day21CompletionDate ?? fromState.day21CompletionDate,
            morningSurveyTimeComponents: morningSurveyTimeComponents ?? fromState.morningSurveyTimeComponents,
            eveningSurveyTimeComponents: eveningSurveyTimeComponents ?? fromState.eveningSurveyTimeComponents,
            day21NotificationFireDate: day21NotificationFireDate ?? fromState.day21NotificationFireDate,
            day212ndNotificationFireDate: day212ndNotificationFireDate ?? fromState.day212ndNotificationFireDate,
            morningNotificationFireDate: morningNotificationFireDate ?? fromState.morningNotificationFireDate,
            morning2ndNotificationFireDate: morning2ndNotificationFireDate ?? fromState.morning2ndNotificationFireDate,
            eveningNotificationFireDate: eveningNotificationFireDate ?? fromState.eveningNotificationFireDate,
            evening2ndNotificationFireDate: evening2ndNotificationFireDate ?? fromState.evening2ndNotificationFireDate,
            enable2ndReminderNotifications: enable2ndReminderNotifications ?? fromState.enable2ndReminderNotifications,
            extensibleStorage: extensibleStorage ?? fromState.extensibleStorage,
            shouldShowTrialActivities: shouldShowTrialActivities ?? fromState.shouldShowTrialActivities,
            debugMode: debugMode ?? fromState.debugMode
        )
    }
    
    
}
