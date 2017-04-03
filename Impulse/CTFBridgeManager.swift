//
//  CTFBridgeManager.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import BridgeSDK
import ResearchSuiteResultsProcessor
import ReSwift

public class CTFBridgeManager: NSObject, RSRPBackEnd, StoreSubscriber {

    var groupLabel: String?
    
    override init() {
        BridgeSDK.setup()
    }
    
    func setAuthDelegate(delegate: SBBAuthManagerDelegateProtocol?) {
        BridgeSDK.setAuthDelegate(delegate)
    }
    
    public func newState(state: CTFReduxState) {
        self.groupLabel = state.groupLabel
    }

    public func isLoggedIn(completion: @escaping ((Bool) -> ())) {
        
        if let authManager: SBBAuthManagerProtocol = SBBComponentManager.component(SBBAuthManager.self) as? SBBAuthManagerProtocol {
            
            self.isLoggedIn(authManager: authManager, completion: completion)
            
        }
        else {
            completion(false)
        }
        
    }
    
    private func isLoggedIn(authManager: SBBAuthManagerProtocol, completion: @escaping ((Bool) -> ())) {
        
        authManager.ensureSignedIn(completion: { (sessionTask, responseObject, err) in
            
            if let error = err as? NSError,
                (error.code == SBBErrorCode.noCredentialsAvailable.rawValue) {
                completion(false)
            }
            else {
                completion(true)
            }
        })
        
    }
    
    //sign in
    public func signIn(username: String, password: String, completion: @escaping ((Error?) -> ())) {
        
        
        if let authManager: SBBAuthManagerProtocol = SBBComponentManager.component(SBBAuthManager.self) as? SBBAuthManagerProtocol {
            
            
            self.isLoggedIn(authManager: authManager, completion: { (loggedIn) in
                
                if loggedIn {
                    completion(CTFBridgeManagerError.alreadySignedIn)
                    return
                }

                authManager.signIn(withEmail: username, password: password, completion: { (task, responseObject, error) in
                    
                    debugPrint(task)
                    debugPrint(responseObject)
                    debugPrint(error)

                    guard let responseDict = responseObject as? [String: Any],
                        responseDict["sessionToken"] as? String != nil else {
                            completion(error)
                            return
                    }
                    
                    completion(nil)
                    return
                    
                })
                
                
            })
            
        }
        else {
            completion(CTFBridgeManagerError.invalidConfig)
        }
        
    }
    
    //sign in
    public func signIn(externalID: String, completion: @escaping ((Error?) -> ())) {
        
        let email = String(format: "jdk288+%@@cornell.edu", externalID)
        let password = externalID
        
        self.signIn(username: email, password: password, completion: completion)
        
    }
    
    public func signOut(completion: @escaping ((Error?) -> ())) {
        if let authManager: SBBAuthManagerProtocol = SBBComponentManager.component(SBBAuthManager.self) as? SBBAuthManagerProtocol {
            
            authManager.signOut(completion: { (task, responseObject, error) in
                
                completion(error)
                
            })
            
        }
        else {
            completion(CTFBridgeManagerError.invalidConfig)
        }
    }
    
    public func restoreBackgroundSession(identifier: String, completionHandler: @escaping () -> Void) {
        
        if let networkManager: SBBNetworkManagerProtocol = SBBComponentManager.component(SBBNetworkManager.self) as? SBBNetworkManagerProtocol  {
            
            networkManager.restoreBackgroundSession(identifier, completionHandler: completionHandler)
            
        }
        else {
            completionHandler()
        }
        
    }
    
    public func add(intermediateResult: RSRPIntermediateResult) {
        
        if let groupLabel = self.groupLabel {
            if intermediateResult.userInfo != nil {
                intermediateResult.userInfo!["groupLabel"] = groupLabel
            }
            else {
                intermediateResult.userInfo = ["groupLabel": groupLabel]
            }
        }
        
        debugPrint(intermediateResult)
        if let dataArchive = intermediateResult.toArchive() {
            dataArchive.encryptAndUploadArchive()
        }
        
    }

}
