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
    @IBOutlet weak var debugModeSwitch: UISwitch!
    
    @IBOutlet weak var versionCell: UITableViewCell!
    
    @IBOutlet weak var showTrialActivitiesCell: UITableViewCell!
    @IBOutlet weak var morningSurveyCell: UITableViewCell!
    @IBOutlet weak var eveningSurveyCell: UITableViewCell!
    @IBOutlet weak var participantSinceCell: UITableViewCell!
    @IBOutlet weak var commentsCell: UITableViewCell!
    @IBOutlet weak var contactUsCell: UITableViewCell!
    @IBOutlet weak var debugModeSwitchCell: UITableViewCell!
    
    var cellsToHideBeforeBaseline: [UITableViewCell] {
        return [
            self.showTrialActivitiesCell,
            self.morningSurveyCell,
            self.eveningSurveyCell,
            self.participantSinceCell,
            self.commentsCell,
            self.contactUsCell,
            self.debugModeSwitchCell,
        ]
    }
    
    static let kSettingsFileName = "settings"
    var settingsSchedule: CTFSchedule?
    var baselineCompleted: Bool = false
    
    let showDebugSwitchDelay = 3.0
    let showDebugSwitchCount = 7
    var currentShowDebugSwitchCount = 0
    
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
        
        self.versionCell.textLabel?.text = self.versionString()
        
        self.baselineCompleted = CTFSelectors.baselineCompletedDate(state) != nil
        
        if !self.baselineCompleted {
            self.cellsToHideBeforeBaseline.forEach({ (cell) in
                cell.contentView.isHidden = true
            })
        }
        else {
            self.cellsToHideBeforeBaseline.forEach({ (cell) in
                cell.contentView.isHidden = false
            })
            
            self.showTrialsSwitch.setOn(CTFSelectors.showTrialActivities(state), animated: true)
            
            self.debugModeSwitchCell.contentView.isHidden = !CTFSelectors.showDebugSwitch(state)
            self.debugModeSwitch.setOn(CTFSelectors.debugMode(state), animated: true)
            
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
        
    }
    
    func versionString() -> String {
        
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            let config = Bundle.main.infoDictionary?["Config"] as? String
        else {
            return "Unknown Version"
        }
        
        return "\(config) Version \(version) (Build \(build))"
        
        
    }
    
    func newState(state: CTFReduxState) {
        
        self.updateUI(state: state)
        self.state = state
        
    }
    
    func delay(_ delay:TimeInterval, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func versionLabelTapped() {
        
        if self.currentShowDebugSwitchCount == 0 {
            self.delay(self.showDebugSwitchDelay) {
                self.currentShowDebugSwitchCount = 0
            }
        }
        
        self.currentShowDebugSwitchCount = self.currentShowDebugSwitchCount + 1
        
        if (self.currentShowDebugSwitchCount >= self.showDebugSwitchCount) {
            self.toggleShowDebugSwitch()
            self.currentShowDebugSwitchCount = 0
        }
        
    }
    
    func toggleShowDebugSwitch() {

        let show = self.debugModeSwitchCell.contentView.isHidden
        let action = CTFActionCreators.showDebugSwitch(show: show)
        self.store?.dispatch(action)
        self.store?.dispatch(CTFActionCreators.setDebugMode(debugMode: false))
        
    }
    
    
    private func scheduleItem(forIdentifier identifier: String) -> CTFScheduleItem? {
        return self.settingsSchedule?.items.filter({ (item) -> Bool in
            return item.identifier == identifier
        }).first
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.baselineCompleted,
            let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            
            //add logout here
            guard let reuseIdentifier = cell.reuseIdentifier else {
                return
            }
            
            if reuseIdentifier == "version_cell" {
                self.versionLabelTapped()
            }
            else {
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
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
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
    
    
    @IBAction func showTrialsChanged(_ sender: UISwitch) {
        
        self.store?.dispatch(CTFActionCreators.showTrialActivities(show: sender.isOn))
        
    }
    
    @IBAction func debugModeChanged(_ sender: UISwitch) {
        self.store?.dispatch(CTFActionCreators.setDebugMode(debugMode: sender.isOn))
    }
    
    

}
