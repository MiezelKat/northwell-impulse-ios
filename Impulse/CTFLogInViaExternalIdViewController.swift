//
//  CTFLogInViaExternalIdViewController.swift
//  Impulse
//
//  Created by James Kizer on 10/4/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import BridgeAppSDK

class CTFLogInViaExternalIdViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    @IBAction func externalIDTapped(_ sender: AnyObject) {
        
        // TODO: syoung 06/09/2016 Implement consent and use onboarding manager for external ID
        // Add consent signature.
        let appDelegate = UIApplication.shared.delegate as! SBAAppInfoDelegate
        appDelegate.currentUser.consentSignature = SBAConsentSignature(identifier: "signature")
        
        // Create a task with an external ID and permissions steps and display the view controller
        let externalIDStep = SBAExternalIDStep(identifier: "externalID")
        let passcodeStep = ORKPasscodeStep(identifier: "passcode")
        passcodeStep.passcodeType = .type4Digit
        let task = ORKOrderedTask(identifier: "registration", steps: [externalIDStep, passcodeStep])
        let vc = SBATaskViewController(task: task, taskRun: nil)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            if (reason == .completed), let appDelegate = UIApplication.shared.delegate as? SBABridgeAppSDKDelegate {
                appDelegate.showAppropriateViewController(false)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
