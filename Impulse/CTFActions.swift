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
