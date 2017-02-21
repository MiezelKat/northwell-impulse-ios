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
        NotificationReducer()
    ])
    
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
                lastCompletedTaskIdentifier: state.lastCompletedTaskIdentifier,
                baselineCompletedDate: state.baselineCompletedDate,
                day21NotificationFireDate: state.day21NotificationFireDate,
                day212ndNotificationFireDate: state.day212ndNotificationFireDate,
                morningNotificationFireDate: state.morningNotificationFireDate,
                morning2ndNotificationFireDate: state.morning2ndNotificationFireDate,
                eveningNotificationFireDate: state.eveningNotificationFireDate,
                evening2ndNotificationFireDate: state.evening2ndNotificationFireDate,
                enable2ndReminderNotifications: state.enable2ndReminderNotifications
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
                lastCompletedTaskIdentifier: state.lastCompletedTaskIdentifier,
                baselineCompletedDate: state.baselineCompletedDate,
                day21NotificationFireDate: state.day21NotificationFireDate,
                day212ndNotificationFireDate: state.day212ndNotificationFireDate,
                morningNotificationFireDate: state.morningNotificationFireDate,
                morning2ndNotificationFireDate: state.morning2ndNotificationFireDate,
                eveningNotificationFireDate: state.eveningNotificationFireDate,
                evening2ndNotificationFireDate: state.evening2ndNotificationFireDate,
                enable2ndReminderNotifications: state.enable2ndReminderNotifications
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
                lastCompletedTaskIdentifier: taskIdentifier,
                baselineCompletedDate: state.baselineCompletedDate,
                day21NotificationFireDate: state.day21NotificationFireDate,
                day212ndNotificationFireDate: state.day212ndNotificationFireDate,
                morningNotificationFireDate: state.morningNotificationFireDate,
                morning2ndNotificationFireDate: state.morning2ndNotificationFireDate,
                eveningNotificationFireDate: state.eveningNotificationFireDate,
                evening2ndNotificationFireDate: state.evening2ndNotificationFireDate,
                enable2ndReminderNotifications: state.enable2ndReminderNotifications
            )
        }
    }
    
    struct CompletionDateReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
            let state = state ?? CTFReduxStore.empty()
            
            var baselineCompletedDate: Date? = state.baselineCompletedDate
            
            switch action {
                
            case let baselineCompletedDateAction as MarkBaselineSurveyCompletedAction:
                baselineCompletedDate = baselineCompletedDateAction.completedDate
                
            default:
                break
            }
            
            return CTFReduxStore(
                activityQueue: state.activityQueue,
                resultsQueue: state.resultsQueue,
                lastCompletedTaskIdentifier: state.lastCompletedTaskIdentifier,
                baselineCompletedDate: baselineCompletedDate,
                day21NotificationFireDate: state.day21NotificationFireDate,
                day212ndNotificationFireDate: state.day212ndNotificationFireDate,
                morningNotificationFireDate: state.morningNotificationFireDate,
                morning2ndNotificationFireDate: state.morning2ndNotificationFireDate,
                eveningNotificationFireDate: state.eveningNotificationFireDate,
                evening2ndNotificationFireDate: state.evening2ndNotificationFireDate,
                enable2ndReminderNotifications: state.enable2ndReminderNotifications
            )
        }
    }
    
    struct NotificationReducer: Reducer {
        func handleAction(action: Action, state: CTFReduxStore?) -> CTFReduxStore {
            let state = state ?? CTFReduxStore.empty()
            
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
                
            default:
                break
            }
            
            return CTFReduxStore(
                activityQueue: state.activityQueue,
                resultsQueue: state.resultsQueue,
                lastCompletedTaskIdentifier: state.lastCompletedTaskIdentifier,
                baselineCompletedDate: state.baselineCompletedDate,
                day21NotificationFireDate: day21NotificationFireDate,
                day212ndNotificationFireDate: day212ndNotificationFireDate,
                morningNotificationFireDate: morningNotificationFireDate,
                morning2ndNotificationFireDate: morning2ndNotificationFireDate,
                eveningNotificationFireDate: eveningNotificationFireDate,
                evening2ndNotificationFireDate: evening2ndNotificationFireDate,
                enable2ndReminderNotifications: state.enable2ndReminderNotifications
            )
        }
    }
    
}

