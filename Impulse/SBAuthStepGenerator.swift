//
//  SBAuthStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 2/8/18.
//  Copyright © 2018 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit
import Gloss
import ResearchSuiteExtensions

open class SBAuthStepGenerator: RSRedirectStepGenerator {

    let _supportedTypes = [
        "SBAuth"
    ]
    
    open override var supportedTypes: [String]! {
        return self._supportedTypes
    }
    
    open override func getDelegate(helper: RSTBTaskBuilderHelper) -> RSRedirectStepDelegate! {
        
        guard let sbManagerProvider = helper.stateHelper as? SBManagerProvider,
            let manager = sbManagerProvider.getManager() else {
                return nil
        }
        
        return manager.authDelegate
    }
    
}
