//
//  CTFGoNoGoStepViewController.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/29/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

enum CTFGoNoGoCueType {
    case go
    case noGo
}

enum CTFGoNoGoTargetType {
    case go
    case noGo
}



enum CTFGoNoGoResponseCode{
    /**
     * correctBlue = user does not tap when rectangle is blue (NoGo target)
     * incorrectBlue = user taps when rectangle is blue ( NoGo target)
     * correctGreen = user taps when rectangle is green (Go target)
     * incorrectGreen = user does not tap when rectangle is green (Go target)
    */
    case correctBlue
    case incorrectBlue
    case correctGreen
    case incorrectGreen
}

struct CTFGoNoGoTrial {
    
    var waitTime: TimeInterval!
    var crossTime : TimeInterval!
    var blankTime:TimeInterval!
    var cueTime: TimeInterval!
    var fillTime : TimeInterval!
    
    var cue: CTFGoNoGoCueType!
    var target: CTFGoNoGoTargetType!
    
    var trialIndex: Int!
    
}

struct CTFGoNoGoTrialResult {
    
    var trial: CTFGoNoGoTrial?
    
    var responseTime: TimeInterval?
    var tapped: Bool?
    
}

extension Array {
    func random() -> Element? {
        if self.count == 0 {
            return nil
        }
        else{
            let index = Int(arc4random_uniform(UInt32(self.count)))
            return self[index]
        }
    }
}

class CTFGoNoGoStepViewController: ORKStepViewController, CTFGoNoGoViewDelegate {

    
    @IBOutlet weak var goNoGoView: CTFGoNoGoView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    var correctFeedbackColor: UIColor? = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    var incorrectFeedbackColor: UIColor? = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    
    var trials: [CTFGoNoGoTrial]?
    var trialResults: [CTFGoNoGoTrialResult]?
    
//    var trialTimer: NSTimer?
//    var trialCompletion: ((NSDate?) -> ())?
    
    var tapTime: Date? = nil
    
    var canceled = false
    
    let RFC3339DateFormatter = DateFormatter()
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override convenience init(step: ORKStep?) {
        let framework = Bundle(for: CTFGoNoGoStepViewController.self)
        self.init(nibName: "CTFGoNoGoStepViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
//        self.restorationClass = CTFGoNoGoStepViewController.self
        guard let goNoGoStep = self.step as? CTFGoNoGoStep,
        let params = goNoGoStep.goNoGoParams else {
            return
        }
        self.trials = self.generateTrials(params)
    }
    
    func coinFlip<T>(_ obj1: T, obj2: T, bias: Float = 0.5) -> T {
        
        let realBias: Float = min(bias, 1.0)
        let flip = Float(arc4random()) /  Float(UInt32.max)
        
        if flip < realBias {
            return obj1
        }
        else {
            return obj2
        }
    }
    
    func generateTrials(_ goNoGoParams:CTFGoNoGoStepParams) -> [CTFGoNoGoTrial]? {
        if let numTrials = goNoGoParams.numTrials {
            return (0..<numTrials).map { index in
                let cueTime: TimeInterval = (goNoGoParams.cueTimeOptions?.random())!
                let cueType: CTFGoNoGoCueType = self.coinFlip(CTFGoNoGoCueType.go, obj2: CTFGoNoGoCueType.noGo)
                let goCueGoTargetProbability: Float = Float(goNoGoParams.goCueTargetProb ?? 0.7)
                let noGoCueGoTargetProbability: Float = 1.0 - Float(goNoGoParams.noGoCueTargetProb ?? 0.7)
                let targetType: CTFGoNoGoTargetType = self.coinFlip(CTFGoNoGoTargetType.go, obj2: CTFGoNoGoTargetType.noGo, bias: (cueType == CTFGoNoGoCueType.go) ? goCueGoTargetProbability: noGoCueGoTargetProbability)
                
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
    
    override convenience init(step: ORKStep?, result: ORKResult?) {
        self.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.RFC3339DateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        self.goNoGoView.delegate = self

        // Do any additional setup after loading the view.
        
        //clear results
        if let trials = self.trials {
            self.performTrials(trials, results: [], completion: { (results) in
                print(results)
                
            
                if !self.canceled {
                    //set results
                    // results is a list that contains all the trial results - Francesco
                    self.calculateAggregateResults(results)
                    self.trialResults = results
                    self.goForward()
                }
            })
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.canceled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var result: ORKStepResult? {
        guard let parentResult = super.result else {
            return nil
        }
        return parentResult
    }
    
    func performTrials(_ trials: [CTFGoNoGoTrial], results: [CTFGoNoGoTrialResult], completion: @escaping ([CTFGoNoGoTrialResult]) -> ()) {
        if self.canceled {
            completion([])
            return
        }
        if let head = trials.first {
            let tail = Array(trials.dropFirst())
            doTrial(head, completion: { (result) in
                var newResults = Array(results)
                newResults.append(result)
                self.performTrials(tail, results: newResults, completion: completion)
            })
        }
        else {
            completion(results)
        }
    }
    
    func delay(_ delay:TimeInterval, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    //impliment trial
    func doTrial(_ trial: CTFGoNoGoTrial, completion: @escaping (CTFGoNoGoTrialResult) -> ()) {
        
        let delay = self.delay
        let goNoGoView = self.goNoGoView
        
        goNoGoView?.state = CTFGoNoGoState.blank
        
        print("Trial number \(trial.trialIndex)")
        
        delay(trial.waitTime) {
            
            goNoGoView?.state = CTFGoNoGoState.cross
            
            delay(trial.crossTime) {
                
                goNoGoView?.state = CTFGoNoGoState.blank
                
                delay(trial.blankTime) {
                    
                    if trial.cue == CTFGoNoGoCueType.go {
                        goNoGoView?.state = CTFGoNoGoState.goCue
                    }
                    else {
                        goNoGoView?.state = CTFGoNoGoState.noGoCue
                    }
                    
                    delay(trial.cueTime!) {
                        
                        if trial.cue == CTFGoNoGoCueType.go {
                            if trial.target == CTFGoNoGoTargetType.go {
                                goNoGoView?.state = CTFGoNoGoState.goCueGoTarget
                            }
                            else {
                                goNoGoView?.state = CTFGoNoGoState.goCueNoGoTarget
                            }
                            
                        }
                        else {
                            if trial.target == CTFGoNoGoTargetType.go {
                                goNoGoView?.state = CTFGoNoGoState.noGoCueGoTarget
                            }
                            else {
                                goNoGoView?.state = CTFGoNoGoState.noGoCueNoGoTarget
                            }
                        }
                        
                        //race for tap and timer expiration
                        let startTime: NSDate = NSDate()
                        print("Start time: \(self.RFC3339DateFormatter.string(from: startTime as Date))")
                        self.tapTime = nil
                        
                        delay(trial.fillTime) {
                            let tapped = self.tapTime != nil
                            let responseTime: TimeInterval = (tapped ? self.tapTime!.timeIntervalSince(startTime as Date) : trial.fillTime) * 1000
                            
                            if let tapTime = self.tapTime {
                                print("Tapped Handler: \(self.RFC3339DateFormatter.string(from: tapTime))")
                            }
                            
                            goNoGoView?.state = CTFGoNoGoState.blank
                            
                            if tapped {
                                if trial.target == CTFGoNoGoTargetType.go {
                                    self.feedbackLabel.text = "Correct! \(String(format: "%0.0f", responseTime)) ms"
                                    self.feedbackLabel.textColor = self.correctFeedbackColor
                                }
                                else {
                                    self.feedbackLabel.text = "Incorrect"
                                    self.feedbackLabel.textColor = self.incorrectFeedbackColor
                                }
                                self.feedbackLabel.isHidden = false
                            }
                            delay(trial.waitTime) {
                                
                                let result = CTFGoNoGoTrialResult(trial: trial, responseTime: responseTime, tapped: tapped)
                                completion(result)
                            }
                            
                            delay(0.6) {
                                self.feedbackLabel.isHidden = true
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    func goNoGoViewDidTap(_ goNoGoView: CTFGoNoGoView) {
        if self.tapTime == nil {
            self.tapTime = Date()
        }
    }
    
    func calculateAggregateResults(_ results:[CTFGoNoGoTrialResult]){
        /**
         * uses data in results to calculate the aggregate results.
        */
        
        let firstThird = (results.count * 1/3) - 1
        let secondThird = (results.count * 2/3) - 1
        print(firstThird)
        print(secondThird)
        print(results.count - 1)
        
        let trialResponseCodeAndTime = results.map{(checkResponse($0.trial, tapped: $0.tapped),$0.responseTime!)}
        print(trialResponseCodeAndTime)
        
        
        //Number of  Total Correct Responses
        let taskNumCorrectResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen || $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let firstThirdNumCorrectResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                            $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let secondThirdNumCorrectResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                                         $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let lastThirdNumCorrectResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                                            $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        print(taskNumCorrectResponses,firstThirdNumCorrectResponses,secondThirdNumCorrectResponses,lastThirdNumCorrectResponses)
        
        // Number of  Total Incorrect Responses
        let taskNumIncorrectResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen || $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let firstThirdNumIncorrectResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen ||
                                                                                              $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let secondThirdNumIncorrectResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen ||
                                                                                                           $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let lastThirdNumIncorrectResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen ||
                                                                                                              $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        print(taskNumIncorrectResponses,firstThirdNumIncorrectResponses,secondThirdNumIncorrectResponses,lastThirdNumIncorrectResponses)
        
        // Number of Correct Blue Responses
        let taskNumCorrectBlueResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let firstThirdNumCorrectBlueResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let secondThirdNumCorrectBlueResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let lastThirdNumCorrectBlueResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        print(taskNumCorrectBlueResponses,firstThirdNumCorrectBlueResponses,secondThirdNumCorrectBlueResponses,lastThirdNumCorrectBlueResponses)
        
        //Number of Correct Green Responses
        let taskNumCorrectGreenResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        let firstThirdNumCorrectGreenResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        let secondThirdNumCorrectGreenResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        let lastThirdNumCorrectGreenResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        print(taskNumCorrectGreenResponses,firstThirdNumCorrectGreenResponses,secondThirdNumCorrectGreenResponses,lastThirdNumCorrectGreenResponses)
        
        // Number of Incorrect Blue Responses
        let taskNumIncorrectBlueResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let firstThirdNumIncorrectBlueResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let secondThirdNumIncorrectBlueResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let lastThirdNumIncorrectBlueResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        print(taskNumIncorrectBlueResponses,firstThirdNumIncorrectBlueResponses,secondThirdNumIncorrectBlueResponses,lastThirdNumIncorrectBlueResponses)
        
        //Number of Incorrect Green Responses
        let taskNumIncorrectGreenResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        let firstThirdNumIncorrectGreenResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        let secondThirdNumIncorrectGreenResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        let lastThirdNumIncorrectGreenResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        print(taskNumIncorrectGreenResponses,firstThirdNumIncorrectGreenResponses,secondThirdNumIncorrectGreenResponses,lastThirdNumIncorrectGreenResponses)
        
        //Mean Accuracy
        let taskMeanAccuracy = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                               $0.0 == CTFGoNoGoResponseCode.correctBlue}.count/(trialResponseCodeAndTime.count)
        let firstThirdMeanAccuracy = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                     $0.0 == CTFGoNoGoResponseCode.correctBlue}.count/(trialResponseCodeAndTime.count)
        let secondThirdMeanAccuracy = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                            $0.0 == CTFGoNoGoResponseCode.correctBlue}.count/(trialResponseCodeAndTime.count)
        let lastThirdMeanAccuracy = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                            $0.0 == CTFGoNoGoResponseCode.correctBlue}.count/(trialResponseCodeAndTime.count)
        print(taskMeanAccuracy,firstThirdMeanAccuracy,secondThirdMeanAccuracy,lastThirdMeanAccuracy)
        
        
        //Mean Response Time
        let taskMeanResponseTime = trialResponseCodeAndTime.map{$0.1}.reduce(0, {$0 + $1})/Double(trialResponseCodeAndTime.count)
        let firstThirdMeanResponseTime = trialResponseCodeAndTime[0...firstThird].map{$0.1}.reduce(0, {$0 + $1})/Double(trialResponseCodeAndTime.count * 1/3)
        let secondThirdMeanResponseTime = trialResponseCodeAndTime[firstThird+1...secondThird].map{$0.1}
                                                                                              .reduce(0, {$0 + $1})/Double(trialResponseCodeAndTime.count * 1/3)
        let lastThirdMeanResponseTime = trialResponseCodeAndTime[secondThird+1...results.count-1].map{$0.1}
                                                                                                 .reduce(0, {$0 + $1})/Double(trialResponseCodeAndTime.count * 1/3)
        print(taskMeanResponseTime,firstThirdMeanResponseTime,secondThirdMeanResponseTime,lastThirdMeanResponseTime)
        
        // Range Response Time
        let taskMaxResponseTime = trialResponseCodeAndTime.map{$0.1}.max()
        let taskMinResponseTime = trialResponseCodeAndTime.map{$0.1}.min()
        let firstThirdMaxResponseTime = trialResponseCodeAndTime[0...firstThird].map{$0.1}.max()
        let firstThirdMinResponseTime = trialResponseCodeAndTime[0...firstThird].map{$0.1}.min()
        let secondThirdMaxResponseTime = trialResponseCodeAndTime[firstThird+1...secondThird].map{$0.1}.max()
        let secondThirdMinResponseTime = trialResponseCodeAndTime[firstThird+1...secondThird].map{$0.1}.min()
        let lastThirdMaxResponseTime = trialResponseCodeAndTime[secondThird+1...results.count-1].map{$0.1}.max()
        let lastThirdMinResponseTime = trialResponseCodeAndTime[secondThird+1...results.count-1].map{$0.1}.min()
        print(taskMaxResponseTime,taskMinResponseTime)
        print(firstThirdMaxResponseTime,firstThirdMinResponseTime)
        print(secondThirdMaxResponseTime,secondThirdMinResponseTime)
        print(lastThirdMaxResponseTime,lastThirdMinResponseTime)
        
        //Variability
        let taskExpression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue:trialResponseCodeAndTime.map{$0.1})])
        let taskStd = taskExpression.expressionValue(with: nil, context: nil)
        let firstThirdExpression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue:trialResponseCodeAndTime[0...firstThird].map{$0.1})])
        let firstThirdStd = firstThirdExpression.expressionValue(with: nil, context: nil)
        let secondThirdExpression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue:trialResponseCodeAndTime[firstThird+1...secondThird].map{$0.1})])
        let secondThirdStd = secondThirdExpression.expressionValue(with: nil, context: nil)
        let lastThirdExpression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue:trialResponseCodeAndTime[secondThird+1...results.count-1].map{$0.1})])
        let lastThirdStd = lastThirdExpression.expressionValue(with: nil, context: nil)
        
        
        
        

        
    }
    
    func checkResponse(_ trial:CTFGoNoGoTrial?,tapped:Bool?) -> CTFGoNoGoResponseCode{
        /**
         checkResponses uses the trial.target and compares to the bool tapped and returns a response code.
         response codes:
            CorrectBlue :Go target and user taps
            IncorrectBlue: Go target and user does not tap
            CorrectGreen: No Go target and user taps
            IncorrectGreen: No Go target and user does not tap
        */
        let targetType: CTFGoNoGoTargetType = (trial!.target)!
        let userResponse: Bool = tapped!
        switch ((targetType,userResponse) ) {
            
        case (CTFGoNoGoTargetType.go, true):
            return CTFGoNoGoResponseCode.correctGreen
        case (CTFGoNoGoTargetType.go, false):
            return CTFGoNoGoResponseCode.incorrectGreen
        case (CTFGoNoGoTargetType.noGo, true):
            return CTFGoNoGoResponseCode.incorrectBlue
        case (CTFGoNoGoTargetType.noGo, false):
            return CTFGoNoGoResponseCode.correctBlue
        default:
            assertionFailure("programming error")
            return CTFGoNoGoResponseCode.correctGreen
        }
        
    }
    
    
    


}