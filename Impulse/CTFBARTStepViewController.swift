//
//  CTFBARTStepViewController.swift
//  Impulse
//
//  Created by James Kizer on 10/17/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

struct CTFBARTTrial {
    var earningsPerPump: Float!
    var maxPayingPumps: Int!
    var trialIndex: Int!
}

struct CTFBARTTrialResult {
    var trial: CTFBARTTrial!
    var numPumps: Int!
    var payout: Float!
    var exploded: Bool!
}

class CTFBARTStepViewController: ORKStepViewController {

    
    
    @IBOutlet weak var balloonImageView: UIImageView!
    
    @IBOutlet weak var trialPayoutLabel: UILabel!
    @IBOutlet weak var totalPayoutLabel: UILabel!
    @IBOutlet weak var taskProgressLabel: UILabel!
    
    @IBOutlet weak var pumpButton: UIButton!
    var _pumpButtonHandler:(() -> ())?
    @IBOutlet weak var collectButton: UIButton!
    var _collectButtonHandler:(() -> ())?
    
    
    
    var trials: [CTFBARTTrial]?
    var trialResults: [CTFBARTTrialResult]?
    
    var canceled = false
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override convenience init(step: ORKStep?) {
        let framework = Bundle(for: CTFBARTStepViewController.self)
        self.init(nibName: "CTFBARTStepViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
        
        guard let bartStep = self.step as? CTFBARTStep,
            let params = bartStep.params
            else {
                return
        }
        
        self.trials = self.generateTrials(params: params)
    }
    
    override convenience init(step: ORKStep?, result: ORKResult?) {
        self.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func generateTrials(params: CTFBARTStepParams) -> [CTFBARTTrial]? {
        if let numTrials = params.numTrials {
            return (0..<numTrials).map { index in
                return CTFBARTTrial(
                    earningsPerPump: params.earningsPerPump,
                    maxPayingPumps: params.maxPayingPumpsPerTrial,
                    trialIndex: index
                )
                
            }
        }
        else {
            return nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //clear results
        if let trials = self.trials {
            self.performTrials(trials, results: [], completion: { (results) in
                print(results)
                
                
                if !self.canceled {
                    //set results
                    // results is a list that contains all the trial results - Francesco
//                    self.calculateAggregateResults(results)
                    self.trialResults = results
                    self.goForward()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func performTrials(_ trials: [CTFBARTTrial], results: [CTFBARTTrialResult], completion: @escaping ([CTFBARTTrialResult]) -> ()) {
        if self.canceled {
            completion([])
            return
        }
        if let head = trials.first {
            let tail = Array(trials.dropFirst())
            self.doTrial(head, completion: { (result) in
                var newResults = Array(results)
                newResults.append(result)
                self.performTrials(tail, results: newResults, completion: completion)
            })
        }
        else {
            completion(results)
        }
    }
    
    
    
    //impliment trial
    func doTrial(_ trial: CTFBARTTrial, completion: @escaping (CTFBARTTrialResult) -> ()) {
        //set initial state
        
        func setupForPump(_ pumpCount: Int) {
            
            self._pumpButtonHandler = {
                
                //compute probability of pop
                //function of pump count
                //probability starts low and eventually gets to 1/2
                let popProb = (trial.maxPayingPumps > pumpCount) ?
                    1.0 / Float( (trial.maxPayingPumps - pumpCount) + 2) :
                    1.0 / 2.0
                
                let popped: Bool = coinFlip(false, obj2: true, bias: popProb)
                
                if popped {
                    print("should pop here")
                }
                else {
                    let increment: CGFloat = (self.view.frame.width / CGFloat(trial.maxPayingPumps * 1000));
                    
                    UIView.animate(
                        withDuration: 0.3,
                        delay: 0.0,
                        usingSpringWithDamping: 0.5,
                        initialSpringVelocity: 0.5,
                        options: UIViewAnimationOptions.curveEaseIn, animations: { 
                            let transform = self.balloonImageView.transform.scaledBy(
                                x: 1.005 * (1.1+increment),
                                y: (1.1+increment)
                            )
                            
                            self.balloonImageView.transform = transform
                        },
                        completion: { (comleted) in
                            setupForPump(pumpCount + 1)
                    })
                }
                
            }
            
            self._collectButtonHandler = {
                let result = CTFBARTTrialResult(
                    trial: trial,
                    numPumps: pumpCount,
                    payout: Float(pumpCount) * trial.earningsPerPump,
                    exploded: false
                )
                
                completion(result)
            }
            
            
            
            
        }
        self.balloonImageView.isHidden = true
        let transform = self.balloonImageView.transform.scaledBy(
            x: 0.0,
            y: 0.0
        )
        
        self.balloonImageView.transform = transform
        
        UIView.animate(
            withDuration: 0.3,
            animations: { 
                self.balloonImageView.isHidden = false
            }) { (completed) in
                setupForPump(0)
        }
        
    }
    
    
    @IBAction func pumpButtonPressed(_ sender: AnyObject) {
        self._pumpButtonHandler?()
    }

    @IBAction func collectButtonPressed(_ sender: AnyObject) {
        self._collectButtonHandler?()
    }
}
