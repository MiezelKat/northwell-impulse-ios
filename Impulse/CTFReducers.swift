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

class CTFReducers: NSObject {
    
    public static let reducer = CombinedReducer([
        ActivityQueueReducer(),
        ResultsQueueReducer(),
        LastCompletedTaskIdentifier(),
        CompletionDateReducer(),
        NotificationReducer(),
        SurveyTimeReducer(),
        ExtensibleStorageReducer(),
        SettingsReducer()
    ])
    
    struct ActivityQueueReducer: Reducer {
        
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()

            switch action {
                
            case let queueActivityAction as QueueActivityAction:
                let newActivityQueue = state.activityQueue + [(queueActivityAction.uuid, queueActivityAction.activityRun)]
                return CTFReduxState.newState(fromState: state, activityQueue: newActivityQueue)
                
            case let completeActivityAction as CompleteActivityAction:
                let newActivityQueue = state.activityQueue.filter({ (uuid: UUID, _) -> Bool in
                    return uuid != completeActivityAction.uuid
                })
                return CTFReduxState.newState(fromState: state, activityQueue: newActivityQueue)
                
            default:
                return state
            }

        }
        
    }
    
    struct ResultsQueueReducer: Reducer {
        
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            switch action {
                
            case let completeActivityAction as CompleteActivityAction:
                if let taskResult = completeActivityAction.taskResult {
                    let newResultsQueue = state.resultsQueue + [(completeActivityAction.uuid, completeActivityAction.activityRun, taskResult)]
                    return CTFReduxState.newState(
                        fromState: state,
                        resultsQueue: newResultsQueue
                    )
                }
                else {
                    return state
                }
                
            case let resultsProcessedAction as ResultsProcessedAction:
                let newResultsQueue = state.resultsQueue.filter({ (uuid: UUID, _, _) -> Bool in
                    return uuid != resultsProcessedAction.uuid
                })
                return CTFReduxState.newState(
                    fromState: state,
                    resultsQueue: newResultsQueue
                )
                
            default:
                return state
            }
        }
    }
    
    struct LastCompletedTaskIdentifier: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            switch action {
                
            case let completeActivityAction as CompleteActivityAction:
                if completeActivityAction.taskResult  != nil {
                    
                    return CTFReduxState.newState(
                        fromState: state,
                        lastCompletedTaskIdentifier: completeActivityAction.activityRun.identifier
                    )
                }
                else {
                    return CTFReduxState.newState(
                        fromState: state,
                        lastCompletedTaskIdentifier: nil
                    )
                }
                
            default:
                return state
            }
            
            
        }
    }
    
    struct CompletionDateReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()

            switch action {
                
            case let completedDateAction as MarkBaselineSurveyCompletedAction:
                return CTFReduxState.newState(
                    fromState: state,
                    baselineCompletedDate: completedDateAction.completedDate
                )
                
            case let completedDateAction as MarkMorningSurveyCompletedAction:
                return CTFReduxState.newState(
                    fromState: state,
                    lastMorningCompletionDate: completedDateAction.completedDate
                )
                
            case let completedDateAction as MarkEveningSurveyCompletedAction:
                return CTFReduxState.newState(
                    fromState: state,
                    lastEveningCompletionDate: completedDateAction.completedDate
                )
                
            case let completedDateAction as MarkDay21SurveyCompletedAction:
                return CTFReduxState.newState(
                    fromState: state,
                    day21CompletionDate: completedDateAction.completedDate
                )
            default:
                return state
            }
            
            
        }
    }
    
    struct NotificationReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            switch action {
                
            case let notificationAction as Set21DayNotificationAction:
                return CTFReduxState.newState(
                    fromState: state,
                    day21NotificationFireDate: notificationAction.initialFireDate,
                    day212ndNotificationFireDate: notificationAction.secondaryFireDate
                )
                
            case let notificationAction as SetMorningNotificationAction:
                return CTFReduxState.newState(
                    fromState: state,
                    morningNotificationFireDate: notificationAction.initialFireDate,
                    morning2ndNotificationFireDate: notificationAction.secondaryFireDate
                )
                
            case let notificationAction as SetEveningNotificationAction:
                return CTFReduxState.newState(
                    fromState: state,
                    eveningNotificationFireDate: notificationAction.initialFireDate,
                    evening2ndNotificationFireDate: notificationAction.secondaryFireDate
                )
                
            case _ as ClearAllNotificationsAction:
                return CTFReduxState.newState(
                    fromState: state,
                    day21NotificationFireDate: nil,
                    day212ndNotificationFireDate: nil,
                    morningNotificationFireDate: nil,
                    morning2ndNotificationFireDate: nil,
                    eveningNotificationFireDate: nil,
                    evening2ndNotificationFireDate: nil
                )
                
            default:
                return state
            }
        }
    }
    
    struct SurveyTimeReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()

            switch action {
                
            case let setTimeAction as SetMorningSurveyTimeAction:
                return CTFReduxState.newState(
                    fromState: state,
                    morningSurveyTimeComponents: setTimeAction.components
                )
                
            case let setTimeAction as SetEveningSurveyTimeAction:
                return CTFReduxState.newState(
                    fromState: state,
                    eveningSurveyTimeComponents: setTimeAction.components
                )
                
            default:
                return state
            }
        }
    }
    
    struct ExtensibleStorageReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()

            switch action {
                
            case let setValueAction as SetValueInExtensibleStorage:
                
                var extensibleStorageDict: [String: NSObject] = state.extensibleStorage
                
                let key = setValueAction.key
                
                if let value = setValueAction.value {
                    extensibleStorageDict[key] = value
                }
                else {
                    extensibleStorageDict.removeValue(forKey: key)
                }
                
                return CTFReduxState.newState(
                    fromState: state,
                    extensibleStorage: extensibleStorageDict
                )
                
            default:
                return state
            }
        }
    }
    
    struct SettingsReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()

            switch action {
                
            case let showTrialsAction as SetShouldShowTrialActivities:
                return CTFReduxState.newState(
                    fromState: state,
                    shouldShowTrialActivities: showTrialsAction.show
                )
                
            default:
                return state
            }
        }
    }
    
    
}

