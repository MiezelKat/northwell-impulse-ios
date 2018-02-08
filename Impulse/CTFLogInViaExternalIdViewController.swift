//
//  CTFLogInViaExternalIdViewController.swift
//  Impulse
//
//  Created by James Kizer on 10/4/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit
import Gloss
import ResearchSuiteTaskBuilder

class CTFLogInViaExternalIdViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    static let LoginStepdentifier = "login step identifier"

    var bridgeManager: CTFBridgeManager? {
        if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
            return appDelegate.bridgeManager
        }
        else {
            return nil
        }
    }
    
    var taskBuilder: CTFTaskBuilderManager? {
        if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
            return appDelegate.taskBuilderManager
        }
        else {
            return nil
        }
    }
    
    @IBAction func externalIDTapped(_ sender: AnyObject) {
        
        if let bridgeManager = self.bridgeManager {
            
            // TODO: syoung 06/09/2016 Implement consent and use onboarding manager for external ID
            // Add consent signature.
            //        let appDelegate = UIApplication.shared.delegate as! SBAAppInfoDelegate
            //        appDelegate.currentUser.consentSignature = SBAConsentSignature(identifier: "signature")
            
            let privacyInfoDict: JSON = [
                "identifier":"visualConsentStep",
                "type":"visualConsent",
                "consentDocumentFilename":"privacyInfo"
            ]
            
            guard let privacyInfoSteps = self.taskBuilder?.rstb.steps(forElement: privacyInfoDict as JsonElement) else {
                return
            }
            
            let consentQuestionStep = ORKQuestionStep(identifier: "consent", title: "Do you agree?", text: "Please select \"Yes\" if you agree with the terms of the privacy policy.", answer: ORKAnswerFormat.booleanAnswerFormat())
            
            consentQuestionStep.isOptional = false
            
            let notConsentedStep = ORKInstructionStep(identifier: "not_consented")
            notConsentedStep.text = "You must complete the consent form with a researcher before continuing."
            
            // Create a task with an external ID and permissions steps and display the view controller
//            let logInStep = CTFBridgeExternalIDStep(identifier: CTFLogInViaExternalIdViewController.LoginStepdentifier, bridgeManager: bridgeManager)
            
            let logInStepDict: JSON = [
                "identifier":CTFLogInViaExternalIdViewController.LoginStepdentifier,
                "type":"SBAuth",
                "title":"Get your participant code",
                "buttonText":"Open",
                "optional": false
            ]
            
            guard let logInSteps = self.taskBuilder?.rstb.steps(forElement: logInStepDict as JsonElement),
                let logInStep = logInSteps.first else {
                return
            }
            
            let passcodeStep = ORKPasscodeStep(identifier: "passcode")
            passcodeStep.passcodeType = .type4Digit
            
            let task = ORKNavigableOrderedTask(identifier: "registration", steps: privacyInfoSteps + [consentQuestionStep, logInStep, passcodeStep, notConsentedStep])
            
            let consentResultSelector = ORKResultSelector(resultIdentifier: "consent")
            let notConsentResultPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: consentResultSelector, expectedAnswer: false)
            let consentNavigationRule = ORKPredicateStepNavigationRule(resultPredicates: [notConsentResultPredicate], destinationStepIdentifiers: ["not_consented"], defaultStepIdentifier: CTFLogInViaExternalIdViewController.LoginStepdentifier, validateArrays: false)
            //        let consentNavigationRule = ORKPredicateStepNavigationRule(resultPredicates: [(notConsentResultPredicate, "not_consented")], destinationStepIdentifiers: "externalID")
            
            task.setNavigationRule(consentNavigationRule, forTriggerStepIdentifier: "consent")
            
            let skipNotConsentRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "")
            
            task.setNavigationRule(skipNotConsentRule, forTriggerStepIdentifier: "passcode")
            
            
            let vc = ORKTaskViewController(task: task, taskRun: nil)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    //TODO: Test case where user logs in but cancels when adding passcode
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            if (reason == .completed), let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
                
                //check to see if we're logged in and passcode is set
                let taskResult = taskViewController.result
                guard let loginStepResult = taskResult.stepResult(forStepIdentifier: CTFLogInViaExternalIdViewController.LoginStepdentifier),
                    let loggedInResult = loginStepResult.firstResult as? ORKBooleanQuestionResult,
                    let booleanAnswer = loggedInResult.booleanAnswer else {
                        return
                }
                
                appDelegate.setLoggedInAndShowViewController(loggedIn: booleanAnswer.boolValue, completion: {})

            }
            else {
                if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
                    appDelegate.signOut()
                }
            }
        }
    }


}
