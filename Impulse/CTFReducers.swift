//
//  CTFReducers.swift
//  Impulse
//
//  Created by James Kizer on 2/20/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

struct ActivityQueueReducer: Reducer {
    
    func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
        let state = state ?? CTFReduxStore.empty()
        
        var newActivityQueue = state.activityQueue
        switch action {
        case let queueActivityAction as QueueActivityAction:
            newActivityQueue = newActivityQueue + [(queueActivityAction.uuid, queueActivityAction.activityRun)]
        case let completeActivityAction as CompleteActivityAction:
            newActivityQueue = newActivityQueue.filter({ (uuid: UUID, _) -> Bool in
                return uuid != completeActivityAction.uuid
            })
            
        default:
            break
        }
        
        return CTFReduxStore(
            activityQueue: newActivityQueue,
            resultsQueue: state.resultsQueue,
            lastCompletedTaskIdentifier: state.lastCompletedTaskIdentifier
        )
    }
    
}

struct ResultsQueueReducer: Reducer {
    
    func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
        let state = state ?? CTFReduxStore.empty()
        
        var newResultsQueue = state.resultsQueue
        
        switch action {
            
        case let completeActivityAction as CompleteActivityAction:
            if let taskResult = completeActivityAction.taskResult {
                newResultsQueue = newResultsQueue + [(completeActivityAction.uuid, completeActivityAction.activityRun, taskResult)]
            }
            
        case let resultsProcessedAction as ResultsProcessedAction:
            newResultsQueue = newResultsQueue.filter({ (uuid: UUID, _, _) -> Bool in
                return uuid != resultsProcessedAction.uuid
            })
            
        default:
            break
        }
        
        return CTFReduxStore(
            activityQueue: state.activityQueue,
            resultsQueue: newResultsQueue,
            lastCompletedTaskIdentifier: state.lastCompletedTaskIdentifier
        )
    }
    
}

struct LastCompletedTaskIdentifier: Reducer {
    func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
        let state = state ?? CTFReduxStore.empty()
        
        var taskIdentifier: String? = state.lastCompletedTaskIdentifier
        
        switch action {
            
        case let completeActivityAction as CompleteActivityAction:
            taskIdentifier = completeActivityAction.activityRun.identifier
            
        default:
            break
        }
        
        return CTFReduxStore(
            activityQueue: state.activityQueue,
            resultsQueue: state.resultsQueue,
            lastCompletedTaskIdentifier: taskIdentifier
        )
    }
}
