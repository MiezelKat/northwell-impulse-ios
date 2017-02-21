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
    
    static func empty() -> CTFReduxStore {
        return CTFReduxStore(
            activityQueue: [],
            resultsQueue: [],
            lastCompletedTaskIdentifier: nil
        )
    }
}
