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
            
            DispatchQueue.main.async {
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
            
        }
        
        do {
            
            self.isLoading = true
            try CTFBridgeManager.sharedManager.signIn(externalID: username) { (error) in
                if error != nil {
                    
                    DispatchQueue.main.async {
                        
                        self.isLoading = false
                        
                        let errorMessage: String = {
                            if let sageError = error as? NSError {
                                return sageError.localizedDescription
                            }
                            else {
                                return "Please check the participant ID"
                            }
                        }()
                        
                        
                        let alertController = UIAlertController(title: "Log in failed", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        
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
                    
                    
                }
                else {
                    DispatchQueue.main.async {
                        
                        self.isLoading = false
                        
                        self.loggedIn = true
                        completion(true)
                        return
                    }
                    return
                }
                
            }
        }
        catch {
            
            DispatchQueue.main.async {
                
                self.isLoading = false
                
                let alertController = UIAlertController(title: "An internal error occurred", message: "If this problem continues, please contact the research coordinator", preferredStyle: UIAlertControllerStyle.alert)
                
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
            return
            
            
        }
        
    }
    
}
