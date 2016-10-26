//
//  CTFBARTResult.swift
//  Impulse
//
//  Created by James Kizer on 10/26/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

struct CTFBARTResultSummary {
    var meanNumberOfPumps: Float!
    var numberOfPumpsRange: Int!
    var numberOfPumpsStdDev: Float!
    var meanNumberOfPumpsAfterExplosion: Float!
    var meanNumberOfPumpsAfterNoExplosion: Float!
    var numberOfExplosions: Int!
    var numberOfBalloons: Int!
    var totalWinnings: Float!
}

class CTFBARTResult: ORKResult {
    
//    var totalSummary: CTFBARTResultSummary!
//    var firstThirdSummary: CTFBARTResultSummary!
//    var secondThirdSummary: CTFBARTResultSummary!
//    var lastThirdSummary: CTFBARTResultSummary!

    var trialResults: [CTFBARTTrialResult]?
    
}
