//
//  CTFResultsProcessorManager.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit
import ResearchSuiteResultsProcessor
import sdlrkx

class CTFResultsProcessorManager: NSObject, StoreSubscriber {
    
    var _pendingResult: (UUID, CTFActivityRun, ORKTaskResult)? = nil
    
    var pendingResult: (UUID, CTFActivityRun, ORKTaskResult)? {
        get {
            return _pendingResult
        }
        set(newPendingResult) {
            if newPendingResult?.0 != _pendingResult?.0 {
                _pendingResult = newPendingResult
                if let result = _pendingResult {
                    self.processResult(
                        uuid: result.0,
                        activityRun: result.1,
                        taskResult: result.2)
                }
                
            }
        }
    }
    
    let resultsProcessorQueue: DispatchQueue
    let rsrp: RSRPResultsProcessor
    let store: Store<CTFReduxState>
    
    init(store: Store<CTFReduxState>, backEnd: RSRPBackEnd) {
        
        self.resultsProcessorQueue = DispatchQueue(label: "CTFResultsProcessorManagerQueue")
        self.rsrp = RSRPResultsProcessor(
            frontEndTransformers: [
                CTFDelayDiscountingRawResultsTransformer.self,
                CTFBARTSummaryResultsTransformer.self,
                CTFGoNoGoSummaryResultsTransformer.self
            ], backEnd: backEnd)
        
        self.store = store
        super.init()
        store.subscribe(self)
        
    }
    
    deinit {
        store.unsubscribe(self)
    }
    
    func processResult(uuid: UUID, activityRun: CTFActivityRun, taskResult: ORKTaskResult) {
        
        //process result
        
        if let resultTransforms = activityRun.resultTransforms {
            self.rsrp.processResult(taskResult: taskResult, resultTransforms: resultTransforms)
        }

        self.pendingResult = nil
        let action = ResultsProcessedAction(uuid: uuid)
        store.dispatch(action)
        
    }
    
    func newState(state: CTFReduxState) {
        
        self.pendingResult = state.resultsQueue.first
        
    }
    

}
