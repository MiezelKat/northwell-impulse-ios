//
//  CTFReduxStateHelper.swift
//  Impulse
//
//  Created by James Kizer on 2/21/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ReSwift
import ResearchSuiteTaskBuilder

class CTFReduxStateHelper: NSObject, RSTBStateHelper, StoreSubscriber {
    
    var state: CTFReduxState?
    
    let store: Store<CTFReduxState>
    
    init(store: Store<CTFReduxState>) {
        self.store = store
        super.init()
    }
    
    func newState(state: CTFReduxState) {
        self.state = state
    }
    
    public func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.store.dispatch(CTFActionCreators.setValueInExtensibleStorage(key: forKey, value: value != nil ? value! as! NSObject : nil))
    }
    
    public func valueInState(forKey: String) -> NSSecureCoding? {
        guard let state = self.state else {
            return nil
        }
        
        return CTFSelectors.getValueInExtensibleStorage(state: state, key: forKey)
    }
    
    deinit {
        debugPrint("\(self) deiniting")
    }
    

}
