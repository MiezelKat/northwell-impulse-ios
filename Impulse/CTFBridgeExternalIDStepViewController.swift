//
//  CTFBridgeExternalIDStepViewController.swift
//  Impulse
//
//  Created by James Kizer on 2/18/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit
import BridgeSDK

class CTFBridgeExternalIDStepViewController: CTFLoginStepViewController {
    
    open override func loginButtonAction(username: String, password: String, completion: @escaping ActionCompletion) {
        
        //validate that username and password are the same
        //do any other future validation
        
        self.loggedIn = false
        
        if (username != password) {
            let alertController = UIAlertController(title: "Log in failed", message: "Participant IDs do not match", preferredStyle: UIAlertControllerStyle.alert)
            
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            completion(false)
            return
        }
        if let authManager: SBBAuthManagerProtocol = SBBComponentManager.component(SBBAuthManager.self) as? SBBAuthManagerProtocol {
            
            let email = String(format: "jdk288+%@@cornell.edu", username)
            let password = password
            authManager.signIn(withEmail: email, password: password, completion: { (task, responseObject, error) in
                
                debugPrint(task)
                debugPrint(responseObject)
                debugPrint(error)
                
                guard let responseDict = responseObject as? [String: Any],
                    responseDict["sessionToken"] as? String != nil else {
                    let alertController = UIAlertController(title: "Log in failed", message: "Please check the participant ID", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    completion(false)
                    return
                }
                
                self.loggedIn = true
                completion(true)
                return
                
            })
            
        }
        else {
            fatalError("A programming error occurred")
        }
            
//        else {
//            completion(true)
//        }
        
//        OhmageOMHManager.shared.signIn(username: username, password: password) { (error) in
//            
//            debugPrint(error)
//            if error == nil {
//                self.loggedIn = true
//                completion(true)
//            }
//            else {
//                self.loggedIn = false
//                DispatchQueue.main.async {
//                    let alertController = UIAlertController(title: "Log in failed", message: "Username / Password are not valid", preferredStyle: UIAlertControllerStyle.alert)
//                    
//                    // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
//                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//                        (result : UIAlertAction) -> Void in
//                        print("OK")
//                    }
//                    
//                    alertController.addAction(okAction)
//                    self.present(alertController, animated: true, completion: nil)
//                    completion(false)
//                }
//                
//            }
//            
//        }
        
    }
    
}
