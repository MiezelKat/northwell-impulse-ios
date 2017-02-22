//
//  CTFReduxState.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/12/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ReSwift
import ResearchKit

class CTFReduxStoreManager: NSObject {
    
    static let sharedInstance = CTFReduxStoreManager()
    static let mainStore = sharedInstance.store
    
    let store: Store<CTFReduxState>
    
    private override init() {
        
        let loggingMiddleware: Middleware = { dispatch, getState in
            return { next in
                return { action in
                    // perform middleware logic
                    let oldState: CTFReduxState? = getState() as? CTFReduxState
                    let retVal = next(action)
                    let newState: CTFReduxState? = getState() as? CTFReduxState
                    
                    print("\n")
                    print("*******************************************************")
                    if let oldState = oldState {
                        print("oldState: \(oldState)")
                    }
                    print("action: \(action)")
                    if let newState = newState {
                        print("newState: \(newState)")
                    }
                    print("*******************************************************\n")
                    
                    // call next middleware
                    return retVal
                }
            }
        }
        
        
        
        let state: CTFReduxState = CTFReduxPersistentStorageSubscriber.sharedInstance.loadState()
        debugPrint(state)
        
        self.store = Store<CTFReduxState>(
            reducer: CTFReducers.reducer,
            state: state,
            middleware: [loggingMiddleware]
        )
        
        super.init()
        
        self.store.subscribe(CTFReduxPersistentStorageSubscriber.sharedInstance)
        self.store.subscribe(CTFNotificationSubscriber.config(state: state))
        self.store.subscribe(CTFReduxStateHelper.sharedInstance)
        
    }
    
}
