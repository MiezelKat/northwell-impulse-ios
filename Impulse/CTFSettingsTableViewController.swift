//
//  CTFSettingsTableViewController.swift
//  Impulse
//
//  Created by James Kizer on 11/17/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit
import ReSwift
import Gloss
import ResearchSuiteTaskBuilder

class CTFSettingsTableViewController: UITableViewController, StoreSubscriber {
    
    @IBOutlet weak var showTrialsSwitch: UISwitch!
    @IBOutlet weak var morningSurveyCell: UITableViewCell!
    @IBOutlet weak var eveningSurveyCell: UITableViewCell!
    @IBOutlet weak var participantSinceCell: UITableViewCell!
    
    static let kSettingsFileName = "settings"
    var settingsSchedule: CTFSchedule?
    
    private var _taskResultFinishedCompletionHandler: ((ORKTaskResult) -> Void)?
    
    var state: CTFReduxState?
    
    var store: Store<CTFReduxState>? {
        if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
            return appDelegate.reduxStoreManager?.store
        }
        else {
            return nil
        }
    }
    
    func loadSchedule(filename: String) -> CTFSchedule? {
        guard let json = CTFTaskBuilderManager.getJson(forFilename: filename) as? JSON else {
            return nil
        }
        
        return CTFSchedule(json: json)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsSchedule = self.loadSchedule(filename: CTFSettingsTableViewController.kSettingsFileName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.store?.subscribe(self)
        if let state = self.store?.state {
            self.updateUI(state: state)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.store?.unsubscribe(self)
    }

    
    func updateUI(state: CTFReduxState) {
        self.showTrialsSwitch.isEnabled = CTFSelectors.baselineCompletedDate(state) != nil
        self.showTrialsSwitch.setOn(CTFSelectors.showTrialActivities(state), animated: true)
        
        if let components = CTFSelectors.morningSurveyTimeComponents(state),
            let hour = components.hour,
            let minute = components.minute {
            
            let timeString = String(format: "%d:%.2d %@", (hour % 12 == 0) ? 12 : hour % 12, minute, (hour / 12 == 0) ? "AM" : "PM")
            print(timeString)
            self.morningSurveyCell.detailTextLabel?.text = timeString
        }
        else {
            self.morningSurveyCell.detailTextLabel?.text = ""
        }
        
        if let components = CTFSelectors.eveningSurveyTimeComponents(state),
            let hour = components.hour,
            let minute = components.minute {
            
            let timeString = String(format: "%d:%.2d %@", (hour % 12 == 0) ? 12 : hour % 12, minute, (hour / 12 == 0) ? "AM" : "PM")
            print(timeString)
            self.eveningSurveyCell.detailTextLabel?.text = timeString
        }
        else {
            self.eveningSurveyCell.detailTextLabel?.text = ""
        }
        
        if let date = CTFSelectors.baselineCompletedDate(state) {
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            let dateString = formatter.string(from: date)
            self.participantSinceCell.detailTextLabel?.text = dateString
        }
        else {
            self.participantSinceCell.detailTextLabel?.text = ""
        }
        
    }
    
    func newState(state: CTFReduxState) {
        
        self.updateUI(state: state)
        self.state = state
        
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
        
//        self.updateUI()
    }
    
    
    private func scheduleItem(forIdentifier identifier: String) -> CTFScheduleItem? {
        return self.settingsSchedule?.items.filter({ (item) -> Bool in
            return item.identifier == identifier
        }).first
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            
            //add logout here
            guard let reuseIdentifier = cell.reuseIdentifier else {
                return
            }
            
            if reuseIdentifier == "signOut" {
                
                let title = "Sign Out"
                let message = "In order to reset your passcode, you'll need to log out of the app completely and log back in using your email and password."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                
                let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                    if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
                        appDelegate.signOut()
                    }
                })
                alert.addAction(logoutAction)
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            guard let state = self.state,
                CTFSelectors.baselineCompletedDate(state) != nil,
                let item = self.scheduleItem(forIdentifier: reuseIdentifier) else {
                return 
            }
            
            let activityRun = CTFActivityRun(
                identifier: item.identifier,
                activity: item.activity as JsonElement,
                resultTransforms: item.resultTransforms,
                onCompletionActions: item.onCompletionActions)
            let action = QueueActivityAction(uuid: UUID(), activityRun: activityRun)
            self.store?.dispatch(action)
        }
    }
    
    @IBAction func showTrialsChanged(_ sender: UISwitch) {
        
        self.store?.dispatch(CTFActionCreators.showTrialActivities(show: sender.isOn))
        
    }
    
    
    
    

}
