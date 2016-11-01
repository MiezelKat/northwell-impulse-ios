//
//  CTFDelayDiscoutingStepViewController.swift
//  Impulse
//
//  Created by Francesco Perera on 10/25/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

enum pressed{
    case NotPressed
    case Now
    case Later
}

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
    
    
    var canceled = false
    var pressedButton = pressed.NotPressed

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
   
    override convenience init(step: ORKStep?) {
        let framework = Bundle(for: CTFDelayDiscoutingStepViewController.self) //check nib creation - Francesco
        self.init(nibName: "CTFDelayDiscoutingStepViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
        
        guard let delayDiscoutingStep = self.step as? CTFDelayDiscoutingStep,
            let params = delayDiscoutingStep.params
            else {
                return
        }
        
//        self.trials = self.generateTrials(params: params)
    
    }
    
    
    func performTrials(_ trial:CTFDelayDiscoutingTrial, trialIds:[Double] ,results: [CTFBARTTrialResult], completion: @escaping ([CTFBARTTrialResult]) -> ()) {
        if self.canceled {
            completion([])
            return
        }
        if let head = trialIds.first {
            //let tail = Array(trials.dropFirst())
            self.doTrial(trial,head, completion: { (result) in
                var newResults = Array(results)
                newResults.append(result)
                //based on the decision made by the user ( click on now or later button),update the next now value
                let nextNow = Double(0) // dummy value - for now
                let nextLater = trial.later!
                let nextDifference = trial.differenceValue/2
                let nextQuestionNum = head + 1
                let nextTrial = CTFDelayDiscoutingTrial(now:nextNow,
                                                        later:nextLater,
                                                        questionNum: nextQuestionNum,
                                                        differenceValue:nextDifference) // check this with James - Francesco
                self.performTrials(nextTrial,head,results: newResults, completion: completion)
            })
        }
        else {
            completion(results)
        }
    }
    
    func doTrial(_ trial: CTFDelayDiscoutingTrial, trialIndex:Double , completion: @escaping (CTFDelayDiscoutingTrialResult) -> ()) {
        // link UI to Trial params
        self.nowButton.setTitle(String(trial.now), for: .normal)
        self.laterButton.setTitle(String(trial.later), for: .normal)
        
        if (self.pressedButton == pressed.Now){
            // return CTFCTFDelayDiscoutingTrialResult(trial,CTFDelayDiscoutingChoice.Now,trial.now, addTime)
        }
        else if (self.pressedButton == pressed.Now){
             // return CTFCTFDelayDiscoutingTrialResult(trial,CTFDelayDiscoutingChoice.Later,trial.later, addTime)
        }
        else{
            print("pressedButton value is: ")
            print(self.pressedButton)
        }
        
    }
    
    
    @IBAction func nowButtonPress(_ sender: AnyObject) {
        if (self.pressedButton != pressed.Now){
            self.pressedButton =  pressed.Now
        }
        
    }
    
    @IBAction func laterButtonPress(_ sender: AnyObject) {
        if (self.pressedButton != pressed.Later){
            self.pressedButton = pressed.Later
            
        }
        
    }
    


}
