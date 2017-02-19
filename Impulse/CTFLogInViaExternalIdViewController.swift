//
//  CTFLogInViaExternalIdViewController.swift
//  Impulse
//
//  Created by James Kizer on 10/4/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

class CTFLogInViaExternalIdViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    static let LoginStepdentifier = "login step identifier"
    
    @IBAction func externalIDTapped(_ sender: AnyObject) {
        
        // TODO: syoung 06/09/2016 Implement consent and use onboarding manager for external ID
        // Add consent signature.
//        let appDelegate = UIApplication.shared.delegate as! SBAAppInfoDelegate
//        appDelegate.currentUser.consentSignature = SBAConsentSignature(identifier: "signature")
        
        let consentQuestionStep = ORKQuestionStep(identifier: "consent", title: "Have you provided consent?", text: "Please select \"Yes\" if you have completed the consent form for the study with a researcher.", answer: ORKAnswerFormat.booleanAnswerFormat())
        
        consentQuestionStep.isOptional = false
        
        let notConsentedStep = ORKInstructionStep(identifier: "not_consented")
        notConsentedStep.text = "You must complete the consent form with a researcher before continuing."
        
        // Create a task with an external ID and permissions steps and display the view controller
        let logInStep = CTFBridgeExternalIDStep(identifier: CTFLogInViaExternalIdViewController.LoginStepdentifier)
        let passcodeStep = ORKPasscodeStep(identifier: "passcode")
        passcodeStep.passcodeType = .type4Digit
        
        
//        let task = ORKNavigableOrderedTask(identifier: "registration", steps: [consentQuestionStep, externalIDStep, passcodeStep, notConsentedStep])
        
        let task = ORKNavigableOrderedTask(identifier: "registration", steps: [consentQuestionStep, logInStep, passcodeStep, notConsentedStep])
        
        let consentResultSelector = ORKResultSelector(resultIdentifier: "consent")
        let notConsentResultPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: consentResultSelector, expectedAnswer: false)
//        let consentNavigationRule = ORKPredicateStepNavigationRule(resultPredicates: [(notConsentResultPredicate, "not_consented")], destinationStepIdentifiers: "externalID")
//        
//        task.setNavigationRule(consentNavigationRule, forTriggerStepIdentifier: "consent")
//        
//        let skipNotConsentRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "")
        
//        task.setNavigationRule(skipNotConsentRule, forTriggerStepIdentifier: "passcode")
        
        
        let vc = ORKTaskViewController(task: task, taskRun: nil)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    //TODO: Test case where user logs in but cancels when adding passcode
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            if (reason == .completed), let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
                
                let taskResult = taskViewController.result
                guard let loginStepResult = taskResult.stepResult(forStepIdentifier: CTFLogInViaExternalIdViewController.LoginStepdentifier),
                    let loggedInResult = loginStepResult.result(forIdentifier: CTFLoginStepViewController.LoggedInResultIdentifier) as? ORKBooleanQuestionResult,
                    let booleanAnswer = loggedInResult.booleanAnswer else {
                        return
                }
                
                var appState: CTFAppStateProtocol = CTFStateManager.defaultManager
                appState.isLoggedIn = booleanAnswer.boolValue
                
                
                
                appDelegate.showViewController()
            }
            else {
                if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
                    appDelegate.signOut()
                }
            }
        }
    }


}
