//
//  CTFBARTStep.swift
//  Impulse
//
//  Created by James Kizer on 10/17/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

struct CTFBARTStepParams {
    
    //number of trials
    var numTrials:Int!
    
    var earningsPerPump: Float!
    var maxPayingPumpsPerTrial: Int!
}

class CTFBARTStep: ORKActiveStep {

    var params:CTFBARTStepParams?
    
    override func stepViewControllerClass() -> AnyClass {
        return CTFBARTStepViewController.self
    }
    
}
