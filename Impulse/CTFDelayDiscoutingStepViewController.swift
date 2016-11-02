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
    var choiceTime: TimeInterval! //time required to make choice
}

class CTFDelayDiscoutingStepViewController: ORKStepViewController {
    
    //UI Elements
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var laterLabel:UILabel!
    @IBOutlet weak var nowButton:UIButton!
    @IBOutlet weak var laterButton:UIButton!
    
    var _nowButtonHandler:(()->())?
    var _laterButtonHandler:(()->())?
    
    
    var canceled = false


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
    
    
    func performTrials(_ trial:CTFDelayDiscoutingTrial, trialIds:[Int] ,results: [CTFDelayDiscoutingTrialResult],
                       completion: @escaping ([CTFDelayDiscoutingTrialResult]) -> ()) {
        if self.canceled {
            completion([])
            return
        }
        if let head = trialIds.first {
            let tail = Array(trialIds.dropFirst())
            //let tail = Array(trials.dropFirst())
            self.doTrial(trial,trialIndex: Int(head), completion: { (result) in
                var newResults = Array(results)
                newResults.append(result)
                //based on the decision made by the user ( click on now or later button),update the next now value
                var nextNow = Double(0) // dummy value - for now
//                switch self.pressedButton{
//                case pressed.Now:
//                    var diff = trial.now - trial.differenceValue
//                case pressed.Later:
//                    var diff = trial.now + trial.differenceValue
//                }
                let nextLater = trial.later!
                let nextDifference = trial.differenceValue/2
                let nextQuestionNum = head + 1
                let nextTrial = CTFDelayDiscoutingTrial(now:nextNow,
                                                        later:nextLater,
                                                        questionNum: Int(nextQuestionNum),
                                                        differenceValue:nextDifference) // check this with James - Francesco
                self.performTrials(nextTrial,trialIds: tail ,results: newResults, completion: completion)
            })
        }
        else {
            completion(results)
        }
    }
    
    func createNewTrial(id:Int,result:CTFDelayDiscoutingTrialResult){}
    
    func doTrial(_ trial: CTFDelayDiscoutingTrial, trialIndex:Int , completion: @escaping (CTFDelayDiscoutingTrialResult) -> ()) {
        // link UI to Trial params
        self.nowButton.setTitle(String(trial.now), for: .normal)
        self.laterButton.setTitle(String(trial.later), for: .normal)
        
        let trialStartTime: Date = Date()
        
        
        func completeTrial(pressAction:CTFDelayDiscoutingChoice){
            let trialEndTime  = Date()
            let amount:Double = (pressAction == .Now) ? trial.now : trial.later
            let result = CTFDelayDiscoutingTrialResult(trial: trial,
                                                       choiceType: pressAction,
                                                       choiceValue: amount,
                                                       choiceTime: trialEndTime.timeIntervalSince(trialStartTime))
            completion(result)
        }
        
        self._nowButtonHandler = {
            completeTrial(pressAction:CTFDelayDiscoutingChoice.Now)
        }
        self._laterButtonHandler = {
            completeTrial(pressAction:CTFDelayDiscoutingChoice.Later)
        }
        
    }
    
    
    @IBAction func nowButtonPress(_ sender: AnyObject) {
      self._nowButtonHandler?()
        
    }
    
    @IBAction func laterButtonPress(_ sender: AnyObject) {
        self._laterButtonHandler?()
        
    }
    
    
    


}
