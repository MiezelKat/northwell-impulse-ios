//
//  CTFSettingsTableViewController.swift
//  Impulse
//
//  Created by James Kizer on 11/17/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

public protocol CTFSettingsDelegate {
    func settingsUpdated()
}

class CTFSettingsTableViewController: UITableViewController, ORKTaskViewControllerDelegate {
    
    var delegate: CTFSettingsDelegate?

    @IBOutlet weak var showTrialsSwitch: UISwitch!
    
    private var _taskResultFinishedCompletionHandler: ((ORKTaskResult) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }

    
    func updateUI() {
        self.showTrialsSwitch.isEnabled = CTFStateManager.defaultManager.isBaselineCompleted
        self.showTrialsSwitch.setOn(CTFStateManager.defaultManager.shouldShowTrialActivities(), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        /*
         The `reason` passed to this method indicates why the task view
         controller finished: Did the user cancel, save, or actually complete
         the task; or was there an error?
         
         The actual result of the task is on the `result` property of the task
         view controller.
         */
        
        self._taskResultFinishedCompletionHandler?(taskViewController.result)
        
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            
            guard CTFStateManager.defaultManager.isBaselineCompleted else {
                return 
            }
            
            switch cell.reuseIdentifier {
            case .some("set_morning_survey"):
                
                let answerFormat = ORKAnswerFormat.timeOfDayAnswerFormat(withDefaultComponents: CTFStateManager.defaultManager.getMorningSurveyTime())
                let questionStep = ORKQuestionStep(identifier: "morning_notification_time_picker_step", title: nil, answer: answerFormat)
                
                questionStep.text = "Please choose a time to be reminded when to perform your morning survey."
                
                let task = ORKOrderedTask(identifier: "morning_notification_time_picker_task", steps: [questionStep])
                
                let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
                
                // Make sure we receive events from `taskViewController`.
                taskViewController.delegate = self
                
                //set result handler
                self._taskResultFinishedCompletionHandler = { result in
                    
                    if let stepResult = result.stepResult(forStepIdentifier: "morning_notification_time_picker_step"),
                        let timeOfDayResult = stepResult.results?.first as? ORKTimeOfDayQuestionResult,
                        let dateComponents = timeOfDayResult.dateComponentsAnswer {
                        
                        CTFStateManager.defaultManager.setMorningSurveyTime(dateComponents)
                    }
                    
                    self.delegate?.settingsUpdated()
                }
                
                // Assign a directory to store `taskViewController` output.
                taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                present(taskViewController, animated: true, completion: nil)
                
                
            case .some("set_evening_survey"):
                
                let answerFormat = ORKAnswerFormat.timeOfDayAnswerFormat(withDefaultComponents: CTFStateManager.defaultManager.getMorningSurveyTime())
                let questionStep = ORKQuestionStep(identifier: "evening_notification_time_picker_step", title: nil, answer: answerFormat)
                
                questionStep.text = "Please choose a time to be reminded when to perform your evening survey."
                
                let task = ORKOrderedTask(identifier: "evening_notification_time_picker_task", steps: [questionStep])
                
                let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
                
                // Make sure we receive events from `taskViewController`.
                taskViewController.delegate = self
                
                //set result handler
                self._taskResultFinishedCompletionHandler = { result in
                    
                    if let stepResult = result.stepResult(forStepIdentifier: "evening_notification_time_picker_step"),
                        let timeOfDayResult = stepResult.results?.first as? ORKTimeOfDayQuestionResult,
                        let dateComponents = timeOfDayResult.dateComponentsAnswer {
                        
                        CTFStateManager.defaultManager.setEveningSurveyTime(dateComponents)
                    }
                    
                    self.delegate?.settingsUpdated()
                }
                
                // Assign a directory to store `taskViewController` output.
                taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                present(taskViewController, animated: true, completion: nil)
                
            default:
                print("do nothing")
            }
        }
    }
    
    @IBAction func showTrialsChanged(_ sender: UISwitch) {
        
        CTFStateManager.defaultManager.setShowTrials(showTrials: sender.isOn)
        self.delegate?.settingsUpdated()
        
    }
    
    
    
    

}
