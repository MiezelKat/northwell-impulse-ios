//
//  CTFReduxStore.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/12/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

struct CTFReduxStore: StateType {
    var activityQueue: [(UUID, CTFActivityRun)] = []
    var resultsQueue: [(UUID, CTFActivityRun, ORKTaskResult)] = []
}

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

struct ActivityQueueReducer: Reducer {
    
    func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
        var state = state ?? CTFReduxStore()
        
        switch action {
        case let queueActivityAction as QueueActivityAction:
            state.activityQueue = state.activityQueue + [(queueActivityAction.uuid, queueActivityAction.activityRun)]
        case let completeActivityAction as CompleteActivityAction:
            state.activityQueue = state.activityQueue.filter({ (uuid: UUID, _) -> Bool in
                return uuid != completeActivityAction.uuid
            })
            
        default:
            break
        }
        
        return state
    }
    
}

struct ResultsQueueReducer: Reducer {
    
    func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
        var state = state ?? CTFReduxStore()
        
        switch action {
            
        case let completeActivityAction as CompleteActivityAction:
            if let taskResult = completeActivityAction.taskResult {
                state.resultsQueue = state.resultsQueue + [(completeActivityAction.uuid, completeActivityAction.activityRun, taskResult)]
            }
            
        case let resultsProcessedAction as ResultsProcessedAction:
            state.resultsQueue = state.resultsQueue.filter({ (uuid: UUID, _, _) -> Bool in
                return uuid != resultsProcessedAction.uuid
            })
            
        default:
            break
        }
        
        return state
    }
    
}

class CTFReduxStoreManager: NSObject {
    
    static let sharedInstance = CTFReduxStoreManager()
    static let mainStore = sharedInstance.store
    
    let store: Store<CTFReduxStore>
    
    private override init() {
        
        let reducer = CombinedReducer([ActivityQueueReducer(), ResultsQueueReducer()])
        self.store = Store<CTFReduxStore>(
            reducer: reducer,
            state: nil
        )
        
        super.init()
        
    }
    
}
