//
//  SBAuthDelegate.swift
//  Impulse
//
//  Created by James Kizer on 2/8/18.
//  Copyright © 2018 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions

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
    private var authCompletion: ((Error?) -> ())? = nil
    
    init(manager: CTFBridgeManager, urlScheme: String) {
        self.urlScheme = urlScheme
        super.init()
        self.manager = manager
    }
    
    public func redirectViewControllerDidLoad(viewController: RSRedirectStepViewController) {
        
    }
    
    public func beginRedirect(completion: @escaping ((Error?) -> ())) {
        
        if let url = self.manager.authURL {
            self.authCompletion = completion
            SBAuthDelegate.safeOpenURL(url: url)
            return
        }
        else {
            self.authCompletion?(nil)
        }
    }
    
    public func handleURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        //check to see if this matches the expected format
        //ancile3ec3082ca348453caa716cc0ec41791e://auth/ancile/callback?code={CODE}
        // dmt3b265a5b19a54f8d99b9c4c49f977744://success?participant_id={PARTICIPANT_ID}
        let pattern = "^\(self.urlScheme)://success"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        guard let _ = regex.firstMatch(
            in: url.absoluteString,
            options: .init(rawValue: 0),
            range: NSMakeRange(0, url.absoluteString.characters.count)) else {
                return false
        }
        
        if let participantID = SBAuthDelegate.getQueryStringParameter(url: url.absoluteString, param: "participant_id") {
//            self.client.signIn(code: code) { (signInResponse, error) in
//                self.authCompletion?(nil)
//            }
//            return true
            
            self.manager.signIn(externalID: participantID, completion: { (error) in
                self.authCompletion?(error)
            })
            return true
        }
        
        return false
    }

}
