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
            
            return CTFReduxState.newState(fromState: state, activityQueue: newActivityQueue)

        }
        
    }
    
    struct ResultsQueueReducer: Reducer {
        
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
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
            
            return CTFReduxState.newState(
                fromState: state,
                resultsQueue: newResultsQueue
            )
        }
        
    }
    
    struct LastCompletedTaskIdentifier: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            var taskIdentifier: String? = state.lastCompletedTaskIdentifier
            
            switch action {
                
            case let completeActivityAction as CompleteActivityAction:
                if completeActivityAction.taskResult  != nil {
                    
                    taskIdentifier = completeActivityAction.activityRun.identifier
                    
                }
                else {
                    taskIdentifier = nil
                }
                
                
            default:
                break
            }
            
            return CTFReduxState.newState(
                fromState: state,
                lastCompletedTaskIdentifier: taskIdentifier
            )
        }
    }
    
    struct CompletionDateReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            var baselineCompletedDate: Date? = state.baselineCompletedDate
            var morningCompletionDate: Date? = state.lastMorningCompletionDate
            var eveningCompletionDate: Date? = state.lastEveningCompletionDate
            var day21CompletionDate: Date? = state.day21CompletionDate
            
            switch action {
                
            case let baselineCompletedDateAction as MarkBaselineSurveyCompletedAction:
                baselineCompletedDate = baselineCompletedDateAction.completedDate
                
            case let completedDateAction as MarkMorningSurveyCompletedAction:
                morningCompletionDate = completedDateAction.completedDate
                
            case let completedDateAction as MarkEveningSurveyCompletedAction:
                eveningCompletionDate = completedDateAction.completedDate
                
            case let completedDateAction as MarkDay21SurveyCompletedAction:
                day21CompletionDate = completedDateAction.completedDate
            default:
                break
            }
            
            return CTFReduxState.newState(
                fromState: state,
                baselineCompletedDate: baselineCompletedDate,
                lastMorningCompletionDate: morningCompletionDate,
                lastEveningCompletionDate: eveningCompletionDate,
                day21CompletionDate: day21CompletionDate
            )
        }
    }
    
    struct NotificationReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            var day21NotificationFireDate: Date? = state.day21NotificationFireDate
            var day212ndNotificationFireDate: Date? = state.day212ndNotificationFireDate
            
            var morningNotificationFireDate: Date? = state.morningNotificationFireDate
            var morning2ndNotificationFireDate: Date? = state.morning2ndNotificationFireDate
            
            var eveningNotificationFireDate: Date? = state.eveningNotificationFireDate
            var evening2ndNotificationFireDate: Date? = state.evening2ndNotificationFireDate
            
            switch action {
                
            case let notificationAction as Set21DayNotificationAction:
                day21NotificationFireDate = notificationAction.initialFireDate
                day212ndNotificationFireDate = notificationAction.secondaryFireDate
                
            case let notificationAction as SetMorningNotificationAction:
                morningNotificationFireDate = notificationAction.initialFireDate
                morning2ndNotificationFireDate = notificationAction.secondaryFireDate
                
            case let notificationAction as SetEveningNotificationAction:
                eveningNotificationFireDate = notificationAction.initialFireDate
                evening2ndNotificationFireDate = notificationAction.secondaryFireDate
                
            case _ as ClearAllNotificationsAction:
                day21NotificationFireDate = nil
                day212ndNotificationFireDate = nil
                morningNotificationFireDate = nil
                morning2ndNotificationFireDate = nil
                eveningNotificationFireDate = nil
                evening2ndNotificationFireDate = nil
                
            default:
                break
            }
            
            return CTFReduxState.newState(
                fromState: state,
                day21NotificationFireDate: day21NotificationFireDate,
                day212ndNotificationFireDate: day212ndNotificationFireDate,
                morningNotificationFireDate: morningNotificationFireDate,
                morning2ndNotificationFireDate: morning2ndNotificationFireDate,
                eveningNotificationFireDate: eveningNotificationFireDate,
                evening2ndNotificationFireDate: evening2ndNotificationFireDate
            )
        }
    }
    
    struct SurveyTimeReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxState?) -> CTFReduxState {
            let state = state ?? CTFReduxState.empty()
            
            var morningSurveyTimeComponents: DateComponents? = state.morningSurveyTimeComponents
            var eveningSurveyTimeComponents: DateComponents? = state.eveningSurveyTimeComponents

            switch action {
                
            case let setTimeAction as SetMorningSurveyTimeAction:
                morningSurveyTimeComponents = setTimeAction.components
                
            case let setTimeAction as SetEveningSurveyTimeAction:
                eveningSurveyTimeComponents = setTimeAction.components
                
            default:
                break
            }
            
            return CTFReduxState.newState(
                fromState: state,
                morningSurveyTimeComponents: morningSurveyTimeComponents,
                eveningSurveyTimeComponents: eveningSurveyTimeComponents
            )
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

