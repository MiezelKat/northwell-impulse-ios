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
    
}

struct CTFDelayDiscoutingTrialResult{
    var trial:CTFDelayDiscoutingTrial!
    var choiceType: CTFDelayDiscoutingChoice!
    var choiceValue: Double!
    var choiceTime:Double! //time required to make choice
}

class CTFDelayDiscoutingStepViewController: ORKStepViewController {
    
    //Adding UI Elements
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var laterLabel:UILabel!
    @IBOutlet weak var nowButton:UIButton!
    @IBOutlet weak var laterButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    


}
