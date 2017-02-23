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
        
        self.initializeState()
        
        var appState: CTFAppStateProtocol = CTFStateManager.defaultManager
        
        CTFBridgeManager.sharedManager.isLoggedIn { (loggedIn) in
            appState.isLoggedIn = loggedIn
            appState.isLoaded = true
            self.showViewController()
        }
        
        return true
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        lockScreen()
        return true
    }
    
    open func showViewController() {
        
        guard let window = self.window else {
            return
        }
        
        var appState: CTFAppStateProtocol = CTFStateManager.defaultManager
        
        if appState.isLoggedIn {
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateInitialViewController() as! CTFMainTabViewController
            
            window.rootViewController = vc
        }
        else {
            let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let vc = onboardingStoryboard.instantiateInitialViewController()
            window.rootViewController = vc
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
            CTFBridgeManager.sharedManager.restoreBackgroundSession(identifier: identifier, completionHandler: completionHandler)
        }
    }
    
    
//
//    func applicationWillResignActive(_ application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//
//    func applicationWillTerminate(_ application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }
    
//    override var requiredPermissions: SBAPermissionsType {
//        return [.coremotion, .localNotifications, .microphone]
//    }
    
//    override func showMainViewController(animated: Bool) {
//        guard let storyboard = openStoryboard("Main"),
//            let vc = storyboard.instantiateInitialViewController()
//            else {
//                assertionFailure("Failed to load onboarding storyboard")
//                return
//        }
//        self.transition(toRootViewController: vc, animated: animated)
//    }
//    
//    override func showOnboardingViewController(animated: Bool) {
//        
//        //clear user keychain
//        do {
//            try ORKKeychainWrapper.resetKeychain()
//        } catch let error {
////            assertionFailure("Got error \(error) when resetting keychain")
//        }
//        
//        guard let storyboard = openStoryboard("Onboarding"),
//            let vc = storyboard.instantiateInitialViewController()
//            else {
//                assertionFailure("Failed to load onboarding storyboard")
//                return
//        }
//        self.transition(toRootViewController: vc, animated: animated)
//    }
//    
//    func openStoryboard(_ name: String) -> UIStoryboard? {
//        return UIStoryboard(name: name, bundle: nil)
//    }

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
            UIView.transition(with: window,
                              duration: 0.6,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                window.rootViewController = toRootViewController
            },
                              completion: nil)
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
    
    private func initializeState() {
        let reduxPersistenceSubscriber = CTFReduxPersistentStorageSubscriber()
        let persistedState = reduxPersistenceSubscriber.loadState()
        let storeManager = CTFReduxStoreManager(initialState: persistedState)
        let notificationManager = CTFNotificationSubscriber()
        let stateHelper = CTFReduxStateHelper(store: storeManager.store)
        
        let taskBuilder = CTFTaskBuilderManager(stateHelper: stateHelper)
        let resultsProcessor = CTFResultsProcessorManager(store: storeManager.store)
        
        self.reduxStoreManager = storeManager
        self.reduxPersistenceSubscriber = reduxPersistenceSubscriber
        self.reduxStateHelper = stateHelper
        self.reduxNotificationSubscriber = notificationManager
        
        self.taskBuilderManager = taskBuilder
        self.resultsProcessorManager = resultsProcessor
        
        storeManager.store.subscribe(reduxPersistenceSubscriber)
        storeManager.store.subscribe(notificationManager)
        storeManager.store.subscribe(stateHelper)
        
    }
    
    private func resetState() {
        
        //unwind
        
        if let oldStoreManager = self.reduxStoreManager {
            if let s = self.reduxPersistenceSubscriber { oldStoreManager.store.unsubscribe(s) }
            if let s = self.reduxStateHelper { oldStoreManager.store.unsubscribe(s) }
            if let s = self.reduxNotificationSubscriber { oldStoreManager.store.unsubscribe(s) }
        }
        
        self.reduxNotificationSubscriber?.cancelAllNotifications()
        
        self.reduxStoreManager = nil
        self.reduxPersistenceSubscriber = nil
        self.reduxStateHelper = nil
        self.reduxNotificationSubscriber = nil
        self.taskBuilderManager = nil
        self.resultsProcessorManager = nil
        
        CTFKeychainHelpers.clearKeychain()
        
        self.initializeState()
        
    }
    
    
//    private func initialize 
    
    public func signOut() {
        
        // Show a plain white view controller while logging out
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        transition(toRootViewController: vc, animated: false)
        
        var appState: CTFAppStateProtocol = CTFStateManager.defaultManager
        CTFBridgeManager.sharedManager.isLoggedIn(completion: { (loggedIn) in
            if loggedIn, let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
                CTFBridgeManager.sharedManager.signOut(completion: { (error) in
                    
                    
                    
                    DispatchQueue.main.async {
                        //clear keychain (passcode stored in keychain
                        appState.isLoggedIn = false
                        self.resetState()
                        appDelegate.showViewController()
                    }
                    
                })
            }
        })
        
    }

}

