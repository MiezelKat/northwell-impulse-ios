//
//  CTFGoNoGoStep.swift
//  ResearchKit
//
//  Created by Francesco Perera on 9/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import Foundation
import ResearchKit


struct CTFGoNoGoStepParams {
    
    // time vars for step
    var waitTime: TimeInterval!
    var crossTime : TimeInterval!
    var blankTime:TimeInterval!
    var cueTimeOptions: [TimeInterval]!
    var fillTime : TimeInterval!
    
    //probabilities for step
    var goCueTargetProb: Double! //refers to probability of green fill
    var noGoCueTargetProb: Double! //refers to probability of blue fill
    var goCueProb:Double! //refers probability to cue orientation
    
    //number of trials
    var numTrials:Int!
    
}


class CTFGoNoGoStep: ORKActiveStep {
    
    var goNoGoParams:CTFGoNoGoStepParams?
    
    override func stepViewControllerClass() -> AnyClass {
        return CTFGoNoGoStepViewController.self
    }
}