//
//  CTFDelayDiscountingStep.swift
//  Impulse
//
//  Created by Francesco Perera on 10/25/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import ResearchKit


struct CTFDelayDiscountingStepParams {
    
    var maxAmount: Double!
    var numQuestions: Int!
    var nowDescription:String!
    var laterDescription:String!
    var formatString: String!
    

}

class CTFDelayDiscountingStep: ORKActiveStep {
    
    static let identifier = "DelayDiscountingStep"
    
    var params:CTFDelayDiscountingStepParams?
    
    override func stepViewControllerClass() -> AnyClass {
        return CTFDelayDiscountingStepViewController.self
    }
    
}
