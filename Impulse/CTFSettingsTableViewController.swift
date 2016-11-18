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
    func showTrialsChanged(_ showTrials: Bool)
}

class CTFSettingsTableViewController: UITableViewController, ORKTaskViewControllerDelegate {
    
    var delegate: CTFSettingsDelegate?

    @IBOutlet weak var showTrialsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        /*
         The `reason` passed to this method indicates why the task view
         controller finished: Did the user cancel, save, or actually complete
         the task; or was there an error?
         
         The actual result of the task is on the `result` property of the task
         view controller.
         */
        
        print(taskViewController.result)
//        if let stepResult = taskViewController.result.stepResult(forStepIdentifier: "locationQuestionStep"),
//            let locationResult = stepResult.results?.first as? ORKLocationQuestionResult,
//            let locationAnswer = locationResult.locationAnswer {
//            print(locationAnswer.coordinate)
//            print(locationAnswer.addressDictionary)
//            print(locationAnswer.region)
//            print(locationAnswer.userInput)
//        }
        
//        taskResultFinishedCompletionHandler?(taskViewController.result)
        
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            switch cell.reuseIdentifier {
            case .some("set_morning_survey"):
                print("launch morning survey setting")
                
                let answerFormat = ORKAnswerFormat.timeOfDayAnswerFormat()
                
                let questionStep = ORKQuestionStep(identifier: "morning_notification_time_picker_step", title: nil, answer: answerFormat)
                
                questionStep.text = "Please choose a time to be reminded when to perform your morning survey."
                
                let task = ORKOrderedTask(identifier: "morning_notification_time_picker_task", steps: [questionStep])
                
                let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
                
                // Make sure we receive events from `taskViewController`.
                taskViewController.delegate = self
                
                // Assign a directory to store `taskViewController` output.
                taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                present(taskViewController, animated: true, completion: nil)
                
                
            case .some("set_evening_survey"):
                print("Launch evening survey setting")
            default:
                print("do nothing")
            }
        }
    }
    
    @IBAction func showTrialsChanged(_ sender: UISwitch) {
        
        self.setShowTrials(showTrials: sender.isOn)
        
    }
    
    func setShowTrials(showTrials: Bool) {
        //set keychain value
        CTFKeychainHelpers.setKeychainObject(showTrials as NSSecureCoding, forKey: kTrialActivitiesEnabled)
        self.delegate?.showTrialsChanged(showTrials)
    }
    
    

}
