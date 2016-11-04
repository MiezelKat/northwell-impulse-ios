//
//  CTFDelayDiscountingStepViewController.swift
//  Impulse
//
//  Created by Francesco Perera on 10/25/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit


enum CTFDelayDiscountingChoice{
    case Now
    case Later
}


struct CTFDelayDiscountingTrial{
    var now:Double!
    var later:Double!
    var questionNum:Int
    var differenceValue:Double!
}

struct CTFDelayDiscountingTrialResult{
    var trial:CTFDelayDiscountingTrial!
    var choiceType: CTFDelayDiscountingChoice!
    var choiceValue: Double!
    var choiceTime: TimeInterval! //time required to make choice
}

class CTFDelayDiscountingStepViewController: ORKStepViewController {
    
    //UI Elements
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var laterLabel:UILabel!
    @IBOutlet weak var nowButton:UIButton!
    @IBOutlet weak var laterButton:UIButton!
    
    var _nowButtonHandler:(()->())?
    var _laterButtonHandler:(()->())?
    
    var trialResults:[CTFDelayDiscountingTrialResult]?
    
    var canceled = false
    
    var stepParams: CTFDelayDiscountingStepParams?{
        guard let delayDiscoutingStep = self.step as? CTFDelayDiscountingStep,
            let params = delayDiscoutingStep.params
            else {
                return nil
        }
        return params
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let stepParams = self.stepParams{
            
            //setup labels
            self.nowLabel.text = stepParams.nowDescription
            self.laterLabel.text = stepParams.laterDescription
            
            let idList = Array(0..<stepParams.numQuestions)
            let idListHead = idList.first!
            let idListTail = Array(idList.dropFirst())
            let firstTrial = CTFDelayDiscountingTrial(now: stepParams.maxAmount/2,
                                                      later: stepParams.maxAmount,
                                                      questionNum: idListHead,
                                                      differenceValue: stepParams.maxAmount/4)
            self.performTrials(firstTrial, trialIds: idListTail, results: [], completion: { (results) in
                if !self.canceled{
                    self.trialResults = results
                    self.goForward()
                }
            })
            

        }
        
    }
   
    override convenience init(step: ORKStep?) {
        let framework = Bundle(for: CTFDelayDiscountingStepViewController.self) //check nib creation - Francesco
        self.init(nibName: "CTFDelayDiscountingStepViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
        
//        guard let delayDiscoutingStep = self.step as? CTFDelayDiscountingStep,
//            let params = delayDiscoutingStep.params
//            else {
//                return
//        }
        
//        self.trials = self.generateTrials(params: params)
    
    }
    
    
    func performTrials(_ trial:CTFDelayDiscountingTrial, trialIds:[Int] ,results: [CTFDelayDiscountingTrialResult],
                       completion: @escaping ([CTFDelayDiscountingTrialResult]) -> ()) {
        if self.canceled {
            completion([])
            return
        }
        self.doTrial(trial) { (result) in
            var newResults = Array(results)
            newResults.append(result)
            if let head = trialIds.first{
                let tail = Array(trialIds.dropFirst())
                let nextTrial = self.createNewTrial(id: head , result: result)
                self.performTrials(nextTrial, trialIds: tail, results: newResults, completion:completion)
                
            }
            else{
                completion(newResults)
            }
        }
//        if let head = trialIds.first {
//            let tail = Array(trialIds.dropFirst())
//            //let tail = Array(trials.dropFirst())
//            self.doTrial(trial,trialIndex: Int(head), completion: { (result) in
//                var newResults = Array(results)
//                newResults.append(result)
//                //call createTrial
//                self.performTrials(nextTrial,trialIds: tail ,results: newResults, completion: completion)
//            })
//        }
//        else {
//            completion(results)
//        }
    }
    
    func createNewTrial(id:Int,result:CTFDelayDiscountingTrialResult)-> CTFDelayDiscountingTrial{
        let newNow = (result.choiceType == CTFDelayDiscountingChoice.Now) ? result.trial.now - result.trial.differenceValue : result.trial.now + result.trial.differenceValue
        let newDifference = result.trial.differenceValue/2
        
        return CTFDelayDiscountingTrial(now:newNow, later: result.trial.later, questionNum: id, differenceValue: newDifference)
    }
    
    func doTrial(_ trial: CTFDelayDiscountingTrial , completion: @escaping (CTFDelayDiscountingTrialResult) -> ()) {
        if let stepParams = self.stepParams{
            // link UI to Trial params
            let nowString = String(format: stepParams.formatString, trial.now)
            let laterString = String(format: stepParams.formatString, trial.later)
            self.nowButton.setTitle(nowString, for: .normal)
            self.laterButton.setTitle(laterString, for: .normal)

        }
        
        let trialStartTime: Date = Date()
        
        
        func completeTrial(pressAction:CTFDelayDiscountingChoice){
            let trialEndTime  = Date()
            let amount:Double = (pressAction == .Now) ? trial.now : trial.later
            let result = CTFDelayDiscountingTrialResult(trial: trial,
                                                       choiceType: pressAction,
                                                       choiceValue: amount,
                                                       choiceTime: trialEndTime.timeIntervalSince(trialStartTime))
            completion(result)
        }
        
        self._nowButtonHandler = {
            completeTrial(pressAction:CTFDelayDiscountingChoice.Now)
        }
        self._laterButtonHandler = {
            completeTrial(pressAction:CTFDelayDiscountingChoice.Later)
        }
        
    }
    
    
    @IBAction func nowButtonPress(_ sender: AnyObject) {
      self._nowButtonHandler?()
        
    }
    
    @IBAction func laterButtonPress(_ sender: AnyObject) {
        self._laterButtonHandler?()
        
    }
    
    
    


}
