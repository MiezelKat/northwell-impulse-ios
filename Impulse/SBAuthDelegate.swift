//
//  SBAuthDelegate.swift
//  Impulse
//
//  Created by James Kizer on 2/8/18.
//  Copyright © 2018 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions

public enum SBAuthError: Error {
    case userCanceled
    case recaptchaValidationFailed
    case otherError
}

open class SBAuthDelegate: NSObject, RSRedirectStepDelegate {
    
    public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    public static func safeOpenURL(url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    private weak var manager: CTFBridgeManager!
    private var urlScheme: String
    private var authCompletion: ((Error?, String?) -> ())? = nil
    
    init(manager: CTFBridgeManager, urlScheme: String) {
        self.urlScheme = urlScheme
        super.init()
        self.manager = manager
    }
    
    public func redirectViewControllerDidLoad(viewController: RSRedirectStepViewController) {
        
    }
    
    public func beginRedirect(completion: @escaping ((Error?, String?) -> ())) {
        
        if let url = self.manager.authURL {
            self.authCompletion = completion
            SBAuthDelegate.safeOpenURL(url: url)
            return
        }
        else {
            self.authCompletion?(nil, nil)
        }
    }
    
    public func handleURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        //check to see if this matches the expected format
        //ancile3ec3082ca348453caa716cc0ec41791e://auth/ancile/callback?code={CODE}
        // dmt3b265a5b19a54f8d99b9c4c49f977744://success?participant_id={PARTICIPANT_ID}
        let successPattern = "^\(self.urlScheme)://success"
        let successRegex = try! NSRegularExpression(pattern: successPattern, options: .caseInsensitive)
        let failurePattern = "^\(self.urlScheme)://failure"
        let failureRegex = try! NSRegularExpression(pattern: failurePattern, options: .caseInsensitive)
        
        if let _ = successRegex.firstMatch(
            in: url.absoluteString,
            options: .init(rawValue: 0),
            range: NSMakeRange(0, url.absoluteString.characters.count)) {
            
            if let participantID = SBAuthDelegate.getQueryStringParameter(url: url.absoluteString, param: "participant_id") {
                //            self.client.signIn(code: code) { (signInResponse, error) in
                //                self.authCompletion?(nil)
                //            }
                //            return true
                
                self.manager.signIn(externalID: participantID, completion: { (error) in
                    self.authCompletion?(error, "Invalid Participant ID")
                })
                return true
            }
            
            return false
            
        }
        else if let _ = failureRegex.firstMatch(
            in: url.absoluteString,
            options: .init(rawValue: 0),
            range: NSMakeRange(0, url.absoluteString.characters.count)) {
            
            if let reason = SBAuthDelegate.getQueryStringParameter(url: url.absoluteString, param: "reason") {
                
                if reason == "recaptcha_validation_failed" {
                    self.authCompletion?(SBAuthError.recaptchaValidationFailed, "Recaptcha Validation Failed")
                    return true
                }
                else if reason == "user_canceled" {
                    self.authCompletion?(SBAuthError.userCanceled, "You must accept the terms")
                    return true
                }
                else {
                    self.authCompletion?(SBAuthError.userCanceled, "An unknown error occurred")
                    return true
                }
                
            }
            
            return false
        }

        
        
        
        
        
        
        return false
    }

}
