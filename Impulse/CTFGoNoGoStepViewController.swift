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
     correctBlue = user does not tap when rectangle is blue (NoGo target)
     incorrectBlue = user taps when rectangle is blue ( NoGo target)
     correctGreen = user taps when rectangle is green (Go target)
     incorrectGreen = user does not tap when rectangle is green (Go target)
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

struct CTFGoNoGoResults {
    // variable label?
    
    var numTrials: Int!
    
    var numCorrectResponsesFull: Int!
    var numCorrectResponsesFirstThird: Int!
    var numCorrectResponsesSecondThird: Int!
    var numCorrectResponsesLastThird: Int!
    
    var numIncorrectResponsesFull: Int!
    var numIncorrectResponsesFirstThird: Int!
    var numIncorrectResponsesSecondThird: Int!
    var numIncorrectResponsesLastThird: Int!
    
    var numCorrectBlueResponsesFull: Int!
    var numCorrectBlueResponsesFirstThird: Int!
    var numCorrectBlueResponsesSecondThird: Int!
    var numCorrectBlueResponsesLastThird: Int!
    
    var numCorrectGreenResponsesFull: Int!
    var numCorrectGreenResponsesFirstThird: Int!
    var numCorrectGreenResponsesSecondThird: Int!
    var numCorrectGreenResponsesLastThird: Int!
    
    var numIncorrectBlueResponsesFull:Int!
    var numIncorrectBlueResponsesFirstThird:Int!
    var numIncorrectBlueResponsesSecondThird:Int!
    var numIncorrectBlueResponsesLastThird:Int!
    
    var numIncorrectGreenResponsesFull:Int!
    var numIncorrectGreenResponsesFirstThird:Int!
    var numIncorrectGreenResponsesSecondThird:Int!
    var numIncorrectGreenResponsesLastThird:Int!

    var meanAccuracyFull:Double!
    var meanAccuracyFirstThird:Double!
    var meanAccuracySecondThird:Double!
    var meanAccuracyLastThird:Double!
    
    var meanResponseTimeFull:Double!
    var meanResponseTimeFirstThird:Double!
    var meanResponseTimeSecondThird:Double!
    var meanResponseTimeLastThird:Double!
    
    var rangeResponseTimeFull:(Double,Double)!
    var rangeResponseTimeFirstThird:(Double,Double)!
    var rangeResponseTimeSecondThird:(Double,Double)!
    var rangeResponseTimeLastThird:(Double,Double)!
    
    var variabilityFull:Double!
    var variabilityFirstThird:Double!
    var variabilitySecondThird:Double!
    var variabilityLastThird:Double!
    
    var avgCorrectResponseTimeFull:Double!
    var avgCorrectResponseTimeFirstThird:Double!
    var avgCorrectResponseTimeSecondThird:Double!
    var avgCorrectResponseTimeLastThird:Double!
    
//    var avgCorrectResponseTimeFull:Double!
//    var avgCorrectResponseTimeFirstThird:Double!
//    var avgCorrectResponseTimeSecondThird:Double!
//    var avgCorrectResponseTimeLastThird:Double!

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
                    self.calculateAllAggregateResults(results)
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
    
    func calculateAllAggregateResults(_ results:[CTFGoNoGoTrialResult]){
        /**
         * uses data in results to calculate the aggregate results.
        */
        
        let firstThird = (results.count * 1/3) - 1
        let secondThird = (results.count * 2/3) - 1
        print(firstThird)
        print(secondThird)
        print(results.count - 1)
        
        let trialResponseCodeAndTime = results.map{(checkResponse($0.trial, tapped: $0.tapped),$0.responseTime!)}
        getResults(responseAndTime: trialResponseCodeAndTime)
        

        
        
        

        
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
    
    func getResults(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) ->  Dictionary<String,Any> {
        var resultsDict = Dictionary<String,Any>()
        resultsDict["numTrials"] = self.calculateNumTrials(responseAndTime: responseAndTime)
        resultsDict["correctResponse"] = self.calculateCorrectResponse(responseAndTime: responseAndTime)
        resultsDict["incorrectResponse"] = self.calculateIncorrectResponse(responseAndTime: responseAndTime)
        resultsDict["correctBlueResponse"] = self.calculateCorrectBlueResponse(responseAndTime: responseAndTime)
        resultsDict["correctGreenResponse"] = self.calculateCorrectGreenResponse(responseAndTime: responseAndTime)
        resultsDict["incorrectBlueResponse"] = self.calculateIncorrectBlueResponse(responseAndTime: responseAndTime)
        resultsDict["incorrectGreenResponse"] = self.calculateIncorrectGreenResponses(responseAndTime: responseAndTime)
        resultsDict["meanAccuracy"] = self.calculateMeanAccuracy(responseAndTime: responseAndTime)
        resultsDict["meanResponseTime"] = self.calculateMeanResponseTime(responseAndTime: responseAndTime)
        resultsDict["rangeResponseTime"] = self.calculateRangeResponseTime(responseAndTime: responseAndTime)
        resultsDict["variability"] = self.calculateVariability(responseAndTime: responseAndTime)
        print(resultsDict)
        return resultsDict
    }
    
    func calculateNumTrials(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int{
        return responseAndTime.count
    }
    
    func calculateCorrectResponse(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int{
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen || $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
    }
    
    func calculateIncorrectResponse(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int {
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen || $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
    }
    
    func calculateCorrectBlueResponse(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int {
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
    }
    
    func calculateCorrectGreenResponse(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int{
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
    }
    
    func calculateIncorrectBlueResponse(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int{
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
    }
    
    func calculateIncorrectGreenResponses(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Int{
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
    }
    
    func calculateMeanAccuracy(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Double{
        return Double(responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen || $0.0 == CTFGoNoGoResponseCode.correctBlue}.count)/Double(responseAndTime.count)
    }
    
    func calculateMeanResponseTime(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Double{
        return responseAndTime.map{$0.1}.reduce(0, {$0 + $1})/Double(responseAndTime.count)
    }
    
    func calculateRangeResponseTime(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> (Double,Double){
        return (responseAndTime.map{$0.1}.min()!,responseAndTime.map{$0.1}.max()!)
    }
    
    func calculateVariability(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Double {
        let expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue:responseAndTime.map{$0.1})])
        return expression.expressionValue(with: nil, context: nil) as! Double
    }
    
    //TODO:create method that calculates average response time after one error - Francesco
    
    //TODO:create method that calculates average response time after a streak of 10 - Francesco

    func calculateAverageResponseTimeCorrect(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Double {
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen || $0.0 == CTFGoNoGoResponseCode.correctBlue}.map{$0.1}.reduce(0, {$0 + $1})/Double(responseAndTime.count)
    }
    
    func calculateAverageResponseTimeIncorrect(responseAndTime:[(CTFGoNoGoResponseCode,TimeInterval)]) -> Double{
        return responseAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen || $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.map{$0.1}.reduce(0, {$0 + $1})/Double(responseAndTime.count)
    }
    
    
}
