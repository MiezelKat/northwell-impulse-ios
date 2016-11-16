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
    
    static let totalAnimationDuration: TimeInterval = 0.3
    
    //UI Elements
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var laterLabel:UILabel!
    @IBOutlet weak var nowButton:CTFBorderedButton!
    @IBOutlet weak var laterButton:CTFBorderedButton!
    @IBOutlet weak var promptLabel: UILabel!
    
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

        self.nowButton.configuredColor = self.view.tintColor
        self.laterButton.configuredColor = self.view.tintColor
        
        self.beforeFirstTrial()
        
        if let stepParams = self.stepParams {
            
            let firstTrial = self.firstTrial(stepParams: stepParams, trialId: 0)
            self.nowLabel.text = stepParams.nowDescription
            self.laterLabel.text = stepParams.laterDescription
            
            // link UI to Trial params
            let nowString = String(format: stepParams.formatString, firstTrial.now)
            let laterString = String(format: stepParams.formatString, firstTrial.later)
            self.nowButton.setTitle(nowString, for: .normal)
            self.laterButton.setTitle(laterString, for: .normal)
            self.promptLabel.text = stepParams.prompt
            
            
        }
        
        
    }
    
    func firstTrial(stepParams: CTFDelayDiscountingStepParams, trialId: Int) -> CTFDelayDiscountingTrial {
        return CTFDelayDiscountingTrial(now: stepParams.maxAmount/2,
                                        later: stepParams.maxAmount,
                                        questionNum: trialId,
                                        differenceValue: stepParams.maxAmount/4)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let stepParams = self.stepParams{
            
            let idList = Array(0..<stepParams.numQuestions)
            let idListHead = idList.first!
            let idListTail = Array(idList.dropFirst())
            let firstTrial = self.firstTrial(stepParams: stepParams, trialId: idListHead)
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
    }
    
    func createNewTrial(id:Int,result:CTFDelayDiscountingTrialResult)-> CTFDelayDiscountingTrial{
        let newNow = (result.choiceType == CTFDelayDiscountingChoice.Now) ? result.trial.now - result.trial.differenceValue : result.trial.now + result.trial.differenceValue
        let newDifference = result.trial.differenceValue/2
        
        return CTFDelayDiscountingTrial(now:newNow, later: result.trial.later, questionNum: id, differenceValue: newDifference)
    }
    
    func beforeFirstTrial() {
        self.nowButton.isEnabled = false
        self.laterButton.isEnabled = false
    }
    
    func doTrial(_ trial: CTFDelayDiscountingTrial , completion: @escaping (CTFDelayDiscountingTrialResult) -> ()) {

        var trialStartTime: Date!
        
        if let stepParams = self.stepParams{
            // link UI to Trial params
            let nowString = String(format: stepParams.formatString, trial.now)
            let laterString = String(format: stepParams.formatString, trial.later)
            self.nowButton.setTitle(nowString, for: .normal)
            self.laterButton.setTitle(laterString, for: .normal)
            
        }
        
        //fade in
        UIView.animate(withDuration: CTFDelayDiscountingStepViewController.totalAnimationDuration / 2.0, animations: {
            
            self.nowButton.titleLabel?.alpha = 1.0
            self.laterButton.titleLabel?.alpha = 1.0
            
            
        }, completion: { (completed) in
            
            
            self.nowButton.isEnabled = true
            self.laterButton.isEnabled = true
            
            trialStartTime = Date()
            
        })

        
        func completeTrial(pressAction:CTFDelayDiscountingChoice){
            let trialEndTime  = Date()
            let amount:Double = (pressAction == .Now) ? trial.now : trial.later
            let result = CTFDelayDiscountingTrialResult(trial: trial,
                                                       choiceType: pressAction,
                                                       choiceValue: amount,
                                                       choiceTime: trialEndTime.timeIntervalSince(trialStartTime))
            
            self.nowButton.isEnabled = false
            self.laterButton.isEnabled = false
            
            //fade out
            UIView.animate(withDuration: CTFDelayDiscountingStepViewController.totalAnimationDuration / 2.0, animations: {
                
                self.nowButton.titleLabel?.alpha = 0.0
                self.laterButton.titleLabel?.alpha = 0.0
                
            }, completion: { completed in
                completion(result)
            })
        
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
