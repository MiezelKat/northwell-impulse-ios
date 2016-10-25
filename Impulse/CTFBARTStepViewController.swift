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

    let initialScalingFactor: CGFloat = 10.0
    
    @IBOutlet weak var balloonContainerView: UIView!
    var balloonImageView: UIImageView!
    var balloonConstraints: [NSLayoutConstraint]?
    
    @IBOutlet weak var trialPayoutLabel: UILabel!
    @IBOutlet weak var totalPayoutLabel: UILabel!
    @IBOutlet weak var taskProgressLabel: UILabel!
    
    @IBOutlet weak var pumpButton: UIButton!
    var _pumpButtonHandler:(() -> ())?
    @IBOutlet weak var collectButton: UIButton!
    var _collectButtonHandler:(() -> ())?
    
    
    
    var trials: [CTFBARTTrial]?
    var trialsCount:Int {
        return self.trials?.count ?? 0
    }
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
        if let trials = self.trials {
            self.setup(trials)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    func setup(_ trials: [CTFBARTTrial]) {
    
        self.collectButton.isEnabled = false
        self.pumpButton.isEnabled = false
        
        self.taskProgressLabel.text = "Ballon 1 out of \(self.trialsCount)."
        self.totalPayoutLabel.text = "$0.00"
    }
    
    func setupImage() {
        
        if let oldConstraints = self.balloonConstraints?.filter({$0.isActive}),
            oldConstraints.count > 0 {
            NSLayoutConstraint.deactivate(oldConstraints)
        }
        
        self.balloonImageView = UIImageView(image: UIImage(named: "balloon"))
        
        self.balloonImageView.alpha = 0.0
        let transform = self.balloonImageView.transform.scaledBy(
            x: 1.0 / self.initialScalingFactor,
            y: 1.0 / self.initialScalingFactor
        )
        
        self.balloonImageView.transform = transform
        self.balloonContainerView.addSubview(self.balloonImageView)
        self.balloonImageView.center = CGPoint(x: self.balloonContainerView.bounds.width/2.0, y: self.balloonContainerView.bounds.height/2.0)
        
    }
    
    
    func performTrials(_ trials: [CTFBARTTrial], results: [CTFBARTTrialResult], completion: @escaping ([CTFBARTTrialResult]) -> ()) {
        
        //set the task progress label and total payout label
        self.taskProgressLabel.text = "Ballon \(results.count + 1) out of \(self.trialsCount)."
        
        let totalPayout: Float = results.reduce(0.0) { (acc, trialResult) -> Float in
            return acc + trialResult.payout
        }
        let monitaryValueString = String(format: "%.2f", totalPayout)
        self.totalPayoutLabel.text = "$\(monitaryValueString)"
        
        if self.canceled {
            completion([])
            return
        }
        if let head = trials.first {
            let tail = Array(trials.dropFirst())
            self.doTrial(head, results.count, completion: { (result) in
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
    func doTrial(_ trial: CTFBARTTrial, _ index: Int, completion: @escaping (CTFBARTTrialResult) -> ()) {

        self.trialPayoutLabel.text = "$0.00"
        
        self.setupImage()
        
        func setupForPump(_ pumpCount: Int) {
            
            self._pumpButtonHandler = {
                
                //compute probability of pop
                //function of pump count
                //probability starts low and eventually gets to 1/2
                let popProb = ((trial.maxPayingPumps-2) >= pumpCount) ?
                    1.0 / Float(trial.maxPayingPumps - pumpCount) :
                    1.0 / 2.0
                
                print(popProb)
                //note for coinFlip, p1 = bias = popProb, p2 = (1.0-bias) = !popProb
                let popped: Bool = coinFlip(true, obj2: false, bias: popProb)
                
                if popped {
                    print("should pop here")
                    
                    self.collectButton.isEnabled = false
                    self.pumpButton.isEnabled = false
                    
                    self.balloonImageView.lp_explode(callback: {
                        let result = CTFBARTTrialResult(
                            trial: trial,
                            numPumps: pumpCount,
                            payout: 0.0,
                            exploded: true
                        )
//                        self.setupImage()
                        completion(result)
                    })
                    
                }
                else {
                    
                    //set potential gain label
                    let monitaryValueString = String(format: "%.2f", trial.earningsPerPump * Float(pumpCount+1))
                    self.trialPayoutLabel.text = "$\(monitaryValueString)"
                    
                    let increment: CGFloat = (self.view.frame.width / CGFloat(trial.maxPayingPumps * 1000))
                    print(increment)
                    let newIncrement = increment * (8.0/(1.0 + CGFloat(pumpCount)))
                    print(newIncrement)
                    
                    UIView.animate(
                        withDuration: 0.3,
                        delay: 0.0,
                        usingSpringWithDamping: 0.5,
                        initialSpringVelocity: 0.5,
                        options: UIViewAnimationOptions.curveEaseIn, animations: { 
                            let transform = self.balloonImageView.transform.scaledBy(
                                x: 1.0025 * (1.0+newIncrement),
                                y: (1.0+newIncrement)
                            )
                            
                            self.balloonImageView.transform = transform
                        },
                        completion: { (comleted) in
                            setupForPump(pumpCount + 1)
                    })
                }
                
            }
            
            self._collectButtonHandler = {
                
                self.collectButton.isEnabled = false
                self.pumpButton.isEnabled = false
                
                // remove balloon
                UIView.animate(withDuration: 0.3, animations: { 
                    self.balloonImageView.alpha = 0.0
                    }, completion: { (completed) in
                        self.balloonImageView.removeFromSuperview()
                        
                        let result = CTFBARTTrialResult(
                            trial: trial,
                            numPumps: pumpCount,
                            payout: Float(pumpCount) * trial.earningsPerPump,
                            exploded: false
                        )
                        
                        completion(result)
                })
                
                
            }

            self.view.isUserInteractionEnabled = true
            
            self.collectButton.isEnabled = pumpCount > 0
            self.pumpButton.isEnabled = true
            
        }
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.balloonImageView.alpha = 1.0
                let transform = self.balloonImageView.transform.scaledBy(
                    x: self.initialScalingFactor,
                    y: self.initialScalingFactor
                )
                
                self.balloonImageView.transform = transform
            },
            completion: { (comleted) in
                setupForPump(0)
        })
        
    }
    
    
    @IBAction func pumpButtonPressed(_ sender: AnyObject) {
        self.view.isUserInteractionEnabled = false
        
        self._pumpButtonHandler?()
    }

    @IBAction func collectButtonPressed(_ sender: AnyObject) {
        self.view.isUserInteractionEnabled = false
        
        self._collectButtonHandler?()
    }
}
