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

class CTFReduxStoreManager: NSObject {
    
    static let sharedInstance = CTFReduxStoreManager()
    static let mainStore = sharedInstance.store
    
    let store: Store<CTFReduxStore>
    
    private override init() {
        
        let loggingMiddleware: Middleware = { dispatch, getState in
            return { next in
                return { action in
                    // perform middleware logic
                    let oldState: CTFReduxStore? = getState() as? CTFReduxStore
                    let retVal = next(action)
                    let newState: CTFReduxStore? = getState() as? CTFReduxStore
                    
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
        
        
        
        let state: CTFReduxStore = CTFReduxPersistentStorageSubscriber.sharedInstance.loadState()
        debugPrint(state)
        
        self.store = Store<CTFReduxStore>(
            reducer: CTFReducers.reducer,
            state: state,
            middleware: [loggingMiddleware]
        )
        
        super.init()
        
        self.store.subscribe(CTFReduxPersistentStorageSubscriber.sharedInstance)
        self.store.subscribe(CTFNotificationSubscriber.config(state: state))
        
    }
    
}
