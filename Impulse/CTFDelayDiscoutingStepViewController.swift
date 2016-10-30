//
//  CTFDelayDiscoutingStepViewController.swift
//  Impulse
//
//  Created by Francesco Perera on 10/25/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

enum CTFDelayDiscoutingChoice{
    case Now
    case Later
}

struct CTFDelayDiscoutingTrial{
    var now:Double!
    var later:Double!
    var questionNum:Int
    var differenceValue:Double!
}

struct CTFDelayDiscoutingTrialResult{
    var trial:CTFDelayDiscoutingTrial!
    var choiceType: CTFDelayDiscoutingChoice!
    var choiceValue: Double!
    var choiceTime:Double! //time required to make choice
}

class CTFDelayDiscoutingStepViewController: ORKStepViewController {
    
    //UI Elements
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var laterLabel:UILabel!
    @IBOutlet weak var nowButton:UIButton!
    @IBOutlet weak var laterButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
   
    override convenience init(step: ORKStep?) {
        let framework = Bundle(for: CTFBARTStepViewController.self) //check nib creation - Francesco
        self.init(nibName: "CTFBARTStepViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
        
        guard let delayDiscoutingStep = self.step as? CTFDelayDiscoutingStep,
            let params = delayDiscoutingStep.params
            else {
                return
        }
        
//        self.trials = self.generateTrials(params: params)
    
    }
    
    func generateTrials(_ delayDiscoutingParams:CTFDelayDiscoutingStepParams) -> [CTFDelayDiscoutingTrial]? {
        if let numQuestions = delayDiscoutingParams.numQuestions {
            return (0..< numQuestions).map { index in
                let questionNum: Int = index + 1
                let laterValue: Double = delayDiscoutingParams.maxAmount
                
                if index == 0 {
                    let nowValue:Double = delayDiscoutingParams.maxAmount/2
                }
                else{
                    
                }
               
                
                return CTFGoNoGoTrial(
                    waitTime: goNoGoParams.waitTime,
                    crossTime: goNoGoParams.crossTime,
                    blankTime: goNoGoParams.blankTime,
                    cueTime: cueTime,
                    fillTime: goNoGoParams.fillTime,
                    cue: cueType,
                    target: targetType,
                    trialIndex: index)
                
            }
        }
        else {
            return nil
        }
    }

    
    
    @IBAction func nowButtonPress(_ sender: AnyObject) {
    }
    
    @IBAction func laterButtonPress(_ sender: AnyObject) {
    }
    


}
