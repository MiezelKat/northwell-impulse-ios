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
    
    static let sharedInstance = CTFResultsProcessorManager()
    
    var pendingResult: UUID?
    
    let resultsProcessorQueue: DispatchQueue
    let rsrp: RSRPResultsProcessor
    
    override init() {
        
        self.resultsProcessorQueue = DispatchQueue(label: "CTFResultsProcessorManagerQueue")
        self.rsrp = RSRPResultsProcessor(
            frontEndTransformers: [
                CTFDelayDiscountingRawResultsTransformer.self,
                CTFBARTSummaryResultsTransformer.self,
                CTFGoNoGoSummaryResultsTransformer.self
            ], backEnd: CTFBridgeManager.sharedManager)
        
        super.init()
        CTFReduxStoreManager.mainStore.subscribe(self)
        
    }
    
    deinit {
        CTFReduxStoreManager.mainStore.unsubscribe(self)
    }
    
    func processResult(uuid: UUID, activityRun: CTFActivityRun, taskResult: ORKTaskResult) {
        
        //process result
        
        if let resultTransforms = activityRun.resultTransforms {
            self.rsrp.processResult(taskResult: taskResult, resultTransforms: resultTransforms)
        }

        self.pendingResult = nil
        let action = ResultsProcessedAction(uuid: uuid)
        CTFReduxStoreManager.mainStore.dispatch(action)
        
    }
    
    func newState(state: CTFReduxStore) {
        
        let pendingResult = self.resultsProcessorQueue.sync {
            return self.pendingResult
        }
        
        if pendingResult == nil,
            let (uuid, activityRun, taskResult) = state.resultsQueue.first {
            
            self.resultsProcessorQueue.async {
                self.processResult(uuid: uuid, activityRun: activityRun, taskResult: taskResult)
            }
            
        }
        
    }
    

}
