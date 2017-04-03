//
//  AppDelegate.swift
//  Impulse
//  Inspiration from SBAAppDelegate.swift in BridgeAppSDK (see below)
//
//  Created by James Kizer on 10/3/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//
//
//  SBAAppDelegate.swift
//  BridgeAppSDK
//
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import ResearchKit
import BridgeSDK
import ResearchSuiteResultsProcessor

@UIApplicationMain
class CTFAppDelegate: UIResponder, UIApplicationDelegate, ORKPasscodeDelegate {

    var window: UIWindow?
    
    var reduxStoreManager: CTFReduxStoreManager?
    
    //the following are subscribers
    var reduxPersistenceSubscriber: CTFReduxPersistentStorageSubscriber?
    var reduxStateHelper: CTFReduxStateHelper?
    var reduxNotificationSubscriber: CTFNotificationSubscriber?
    
    var taskBuilderManager: CTFTaskBuilderManager?
    var resultsProcessorManager: CTFResultsProcessorManager?
    var bridgeManager: CTFBridgeManager?
    
    var rsrpBackEnd: RSRPBackEnd? {
        return self.bridgeManager
    }
    
    var initializeStateClosure: (() -> Void)?
    var resetStateClosure: (() -> Void)?
    
    open var containerRootViewController: CTFRootViewControllerProtocol? {
        return window?.rootViewController as? CTFRootViewControllerProtocol
    }
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            do {
                try ORKKeychainWrapper.resetKeychain()
            } catch let error {
                print("Got error \(error) when resetting keychain")
            }
        }
        
        let bridgeManager = CTFBridgeManager()
        
        self.initializeStateClosure = {
            self.initializeState(bridgeManager: bridgeManager, backEnd: bridgeManager)
        }
        
        self.resetStateClosure = {
            self.resetState(bridgeManager: bridgeManager, backEnd: bridgeManager)
        }
    
        self.bridgeManager = bridgeManager
        
        self.initializeStateClosure!()
        
        let store = self.reduxStoreManager?.store
        bridgeManager.isLoggedIn { (loggedIn) in
            
            self.setLoggedInAndShowViewController(loggedIn: loggedIn, completion: {
                store?.dispatch(CTFActionCreators.setAppLoaded(loaded: true))
            })
            
        }
        
        return true
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        lockScreen()
        return true
    }
    
    open func setLoggedInAndShowViewController(loggedIn: Bool, completion: @escaping () -> Void) {
        let store = self.reduxStoreManager?.store
        store?.dispatch(CTFActionCreators.setLoggedIn(loggedIn: loggedIn), callback: { (state) in
            self.showViewController(state: state)
            completion()
        })
    }
    
    open func showViewController(state: CTFReduxState) {
        
        guard let window = self.window else {
            return
        }
        
        
        //check for case where a failure occurs during login
        if CTFSelectors.isLoggedIn(state) && !ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            self.signOut()
        }

        if CTFSelectors.isLoggedIn(state) && ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            
            guard (window.rootViewController as? CTFMainTabViewController) == nil else {
                return
            }
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = mainStoryboard.instantiateInitialViewController() as? CTFMainTabViewController {
                self.transition(toRootViewController: vc, animated: true)
            }

            
        }
        else {
            guard (window.rootViewController as? CTFLogInViaExternalIdViewController) == nil else {
                return
            }
            
            let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
            if let vc = onboardingStoryboard.instantiateInitialViewController() as? CTFLogInViaExternalIdViewController {
                self.transition(toRootViewController: vc, animated: true)
            }
            
        }
        
        return
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        if shouldShowPasscode() {
            // Hide content so it doesn't appear in the app switcher.
            if var vc = containerRootViewController {
                vc.contentHidden = true
            }
            
        }
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        // Make sure that the content view controller is not hiding content
        if var vc = containerRootViewController {
            vc.contentHidden = false
        }
        
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        lockScreen()
    }
    
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == kBackgroundSessionIdentifier {
            self.bridgeManager!.restoreBackgroundSession(identifier: identifier, completionHandler: completionHandler)
        }
    }

    /**
     Convenience method for presenting a modal view controller.
     */
    open func presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let rootVC = self.window?.rootViewController else { return }
        var topViewController: UIViewController = rootVC
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        topViewController.present(viewController, animated: animated, completion: completion)
    }
    
    /**
     Convenience method for transitioning to the given view controller as the main window
     rootViewController.
     */
    open func transition(toRootViewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        if (animated) {
            let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
            toRootViewController.view.addSubview(snapshot);
            
            self.window?.rootViewController = toRootViewController;
            
            UIView.animate(withDuration: 0.3, animations: {() in
                snapshot.layer.opacity = 0;
            }, completion: {
                (value: Bool) in
                snapshot.removeFromSuperview()
            })
        }
        else {
            window.rootViewController = toRootViewController
        }
    }
    
    // ------------------------------------------------
    // MARK: Passcode Display Handling
    // ------------------------------------------------
    
    private weak var passcodeViewController: UIViewController?
    
    /**
     Should the passcode be displayed. By default, if there isn't a catasrophic error,
     the user is registered and there is a passcode in the keychain, then show it.
     */
    open func shouldShowPasscode() -> Bool {
        return (self.passcodeViewController == nil) &&
            ORKPasscodeViewController.isPasscodeStoredInKeychain()
    }
    
    private func instantiateViewControllerForPasscode() -> UIViewController? {
        return ORKPasscodeViewController.passcodeAuthenticationViewController(withText: nil, delegate: self)
    }
    
    public func lockScreen() {
        
        guard self.shouldShowPasscode(), let vc = instantiateViewControllerForPasscode() else {
            return
        }
        
        window?.makeKeyAndVisible()
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        passcodeViewController = vc
        presentViewController(vc, animated: false, completion: nil)
    }
    
    private func dismissPasscodeViewController(_ animated: Bool) {
        self.passcodeViewController?.presentingViewController?.dismiss(animated: animated, completion: nil)
    }
    
    private func resetPasscode() {
        
        // Dismiss the view controller unanimated
        dismissPasscodeViewController(false)
        
        self.signOut()
    }
    
    // MARK: ORKPasscodeDelegate
    
    open func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        dismissPasscodeViewController(true)
    }
    
    open func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // Do nothing in default implementation
    }
    
    open func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
        
        let title = "Reset Passcode"
        let message = "In order to reset your passcode, you'll need to log out of the app completely and log back in using your email and password."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.resetPasscode()
        })
        alert.addAction(logoutAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func initializeState(bridgeManager: CTFBridgeManager, backEnd: RSRPBackEnd) {
        let reduxPersistenceSubscriber = CTFReduxPersistentStorageSubscriber()
        let persistedState = reduxPersistenceSubscriber.loadState()
        let storeManager = CTFReduxStoreManager(initialState: persistedState)
        let notificationManager = CTFNotificationSubscriber()
        let stateHelper = CTFReduxStateHelper(store: storeManager.store)
        
        bridgeManager.setAuthDelegate(delegate: stateHelper)
        
        let taskBuilder = CTFTaskBuilderManager(stateHelper: stateHelper)
        let resultsProcessor = CTFResultsProcessorManager(store: storeManager.store, backEnd: backEnd)
        
        self.reduxStoreManager = storeManager
        self.reduxPersistenceSubscriber = reduxPersistenceSubscriber
        self.reduxStateHelper = stateHelper
        self.reduxNotificationSubscriber = notificationManager
        
        self.taskBuilderManager = taskBuilder
        self.resultsProcessorManager = resultsProcessor
        
        storeManager.store.subscribe(reduxPersistenceSubscriber)
        storeManager.store.subscribe(notificationManager)
        storeManager.store.subscribe(stateHelper)
        storeManager.store.subscribe(bridgeManager)
        
    }
    
    private func resetState(bridgeManager: CTFBridgeManager, backEnd: RSRPBackEnd) {
        
        bridgeManager.setAuthDelegate(delegate: nil)
        //unwind
        
        if let oldStoreManager = self.reduxStoreManager {
            if let s = self.reduxPersistenceSubscriber { oldStoreManager.store.unsubscribe(s) }
            if let s = self.reduxStateHelper { oldStoreManager.store.unsubscribe(s) }
            if let s = self.reduxNotificationSubscriber { oldStoreManager.store.unsubscribe(s) }
            oldStoreManager.store.unsubscribe(bridgeManager)
        }
        
        self.reduxNotificationSubscriber?.cancelAllNotifications()
        
        self.reduxStoreManager = nil
        self.reduxPersistenceSubscriber = nil
        self.reduxStateHelper = nil
        self.reduxNotificationSubscriber = nil
        self.taskBuilderManager = nil
        self.resultsProcessorManager = nil

        CTFKeychainManager.clearKeychain()
        
        self.initializeState(bridgeManager: bridgeManager, backEnd: backEnd)
        
    }
    
    public func signOut() {
        
        // Show a plain white view controller while logging out
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        transition(toRootViewController: vc, animated: false)
        
        let finishedClosure = {
            DispatchQueue.main.async {
                //clear keychain (passcode stored in keychain
                self.resetStateClosure!()
                self.setLoggedInAndShowViewController(loggedIn: false, completion: {
                    
                })
            }
        }
        
        if let bridgeManager = self.bridgeManager {
            bridgeManager.isLoggedIn(completion: { (loggedIn) in
                if loggedIn {
                    bridgeManager.signOut(completion: { (error) in
                        
                        finishedClosure()
                        
                    })
                }
                else {
                    finishedClosure()
                }
            })
        }
        else {
            finishedClosure()
        }

        
        
    }

}

