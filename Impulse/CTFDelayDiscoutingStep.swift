//
//  CTFDelayDiscoutingStep.swift
//  Impulse
//
//  Created by Francesco Perera on 10/25/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import ResearchKit


struct CTFDelayDiscoutingStepParams {
    

}

class CTFDelayDiscoutingStep: ORKActiveStep {
    
    var params:CTFDelayDiscoutingStepParams?
    
    override func stepViewControllerClass() -> AnyClass {
        return CTFDelayDiscoutingStepViewController.self
    }
    
}
