//
//  AppDelegate.swift
//  Impulse
//
//  Created by James Kizer on 10/3/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import BridgeAppSDK

@UIApplicationMain
class AppDelegate: SBAAppDelegate {
//
//    var window: UIWindow?
//
//
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
    
    override func showMainViewController(animated: Bool) {
        guard let storyboard = openStoryboard("Main"),
            let vc = storyboard.instantiateInitialViewController()
            else {
                assertionFailure("Failed to load onboarding storyboard")
                return
        }
        self.transition(toRootViewController: vc, animated: animated)
    }
    
    override func showOnboardingViewController(animated: Bool) {
        
        //clear user keychain
        do {
            try ORKKeychainWrapper.resetKeychain()
        } catch let error {
//            assertionFailure("Got error \(error) when resetting keychain")
        }
        
        guard let storyboard = openStoryboard("Onboarding"),
            let vc = storyboard.instantiateInitialViewController()
            else {
                assertionFailure("Failed to load onboarding storyboard")
                return
        }
        self.transition(toRootViewController: vc, animated: animated)
    }
    
    func openStoryboard(_ name: String) -> UIStoryboard? {
        return UIStoryboard(name: name, bundle: nil)
    }


}

