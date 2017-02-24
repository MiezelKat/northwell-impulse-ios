//
//  CTFReduxStateHelper+SBBAuthManagerDelegate.swift
//  Impulse
//
//  Created by James Kizer on 2/23/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import BridgeSDK

extension CTFReduxStateHelper: SBBAuthManagerDelegateProtocol {
    
    
    /*!
     *  The auth manager will call this delegate method when it obtains a new session token, so that the delegate
     *  can store the new sessionToken as well as the email and password used to obtain it, to be returned later in
     *  the sessionTokenForAuthManager:, emailForAuthManager:, and passwordForAuthManager: calls, respectively.
     *
     *  This method provides a convenient interface for keeping track of the auth credentials used in the most recent successful signIn, for re-use when automatically refreshing an expired session token.
     *
     *  @note This method is now required, and once it has been called, the emailForAuthManager: and passwordForAuthManager: delegate methods must return valid credentials.
     *
     *  @param authManager The auth manager instance making the delegate request.
     *  @param sessionToken The session token just obtained by the auth manager.
     *  @param email The email used when signing in to obtain this session token.
     *  @param password The password used when signing in to obtain this session token.
     */
    public func authManager(_ authManager: SBBAuthManagerProtocol?, didGetSessionToken sessionToken: String?, forEmail email: String?, andPassword password: String?) {

        self.store.dispatch(CTFActionCreators.setBridgeCredentials(sessionToken: sessionToken, email: email, password: password))
        
    }
    
    /*!
     *  This delegate method should return the session token for the current signed-in user session,
     *  or nil if not currently signed in to any account.
     *
     *  @note This method is required.
     *
     *  @param authManager The auth manager instance making the delegate request.
     *
     *  @return The session token, or nil.
     */
    public func sessionToken(forAuthManager authManager: SBBAuthManagerProtocol) -> String? {
        
        if let state = self.state {
            return CTFSelectors.sessionToken(state)
        }
        else {
            return nil
        }
        
    }
    
    
    /*!
     *  This delegate method should return the email for the user account last signed up for or signed in to,
     *  or nil if the user has never signed up or signed in on this device.
     *
     *  @note This method is now required, so that the SDK can handle refreshing the session token automatically when 401 status codes are received from the Bridge API.
     *
     *  @param authManager The auth manager instance making the delegate request.
     *
     *  @return The email for the user account, or nil.
     */
    public func email(forAuthManager authManager: SBBAuthManagerProtocol?) -> String? {
        if let state = self.state {
            return CTFSelectors.email(state)
        }
        else {
            return nil
        }
    }
    
    
    /*!
     *  This delegate method should return the password for the user account last signed up for or signed in to,
     *  or nil if the user has never signed up or signed in on this device.
     *
     *  @note This method is now required. The password is used when encrypting sensitive user data in CoreData, and also for refreshing the session token automatically when 401 status codes are received from the Bridge API.
     *
     *  @param authManager The auth manager instance making the delegate request.
     *
     *  @return The password, or nil.
     */
    public func password(forAuthManager authManager: SBBAuthManagerProtocol?) -> String? {
        if let state = self.state {
            return CTFSelectors.password(state)
        }
        else {
            return nil
        }
    }

}
