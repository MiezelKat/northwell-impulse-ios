//
//  CTFActions.swift
//  Impulse
//
//  Created by James Kizer on 2/20/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

struct QueueActivityAction: Action {
    let uuid: UUID
    let activityRun: CTFActivityRun
}

struct CompleteActivityAction: Action {
    let uuid: UUID
    let activityRun: CTFActivityRun
    let taskResult: ORKTaskResult?
}

struct ResultsProcessedAction: Action {
    let uuid: UUID
}

struct MarkBaselineSurveyCompletedAction: Action {
    let completedDate: Date
}

struct Set21DayNotificationAction: Action {
    let initialFireDate: Date
    let secondaryFireDate: Date
}

struct SetMorningNotificationAction: Action {
    let initialFireDate: Date
    let secondaryFireDate: Date
}

struct SetEveningNotificationAction: Action {
    let initialFireDate: Date
    let secondaryFireDate: Date
}

struct Enable2ndNotificationAction: Action {
    let enable: Bool
}

