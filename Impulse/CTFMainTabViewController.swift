//
//  MainTabViewController.swift
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
//import BridgeAppSDK
import ReSwift
import ResearchKit

class CTFMainTabViewController: UITabBarController, CTFRootViewControllerProtocol, StoreSubscriber {
    
    var presentedActivity: UUID?
    
    var contentHidden = false {
        didSet {
            guard contentHidden != oldValue && isViewLoaded else { return }
            self.childViewControllers.first?.view.isHidden = contentHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CTFReduxStoreManager.mainStore.subscribe(self)
        
        //force results processor init
        _ = CTFResultsProcessorManager.sharedInstance
    }
    
    deinit {
        CTFReduxStoreManager.mainStore.unsubscribe(self)
    }
    
    func newState(state: CTFReduxState) {
        
        if self.presentedActivity == nil,
            let (uuid, activityRun) = state.activityQueue.first {
            
            self.runActivity(uuid: uuid, activityRun: activityRun)
            
        }
        
        debugPrint(CTFSelectors.getValueInExtensibleStorage(state: state, key: "BaselineBehaviorResults"))
        
    }
    
    func runActivity(uuid: UUID, activityRun: CTFActivityRun) {
        
        guard let steps = CTFTaskBuilderManager.sharedBuilder.steps(forElement: activityRun.activity) else {
            return
        }
        
        
        
        let task = ORKOrderedTask(identifier: activityRun.identifier, steps: steps)
        
        let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { [weak self] (taskViewController, reason, error) in
            
            self?.dismiss(animated: true, completion: {
                self?.presentedActivity = nil
                
                let taskResult: ORKTaskResult? = (reason == ORKTaskViewControllerFinishReason.completed) ?
                    taskViewController.result : nil
                
                let action = CompleteActivityAction(uuid: uuid, activityRun: activityRun, taskResult: taskResult)
                CTFReduxStoreManager.mainStore.dispatch(action)
            })
            
        }
        
        let taskViewController = CTFTaskViewController(task: task, taskFinishedHandler: taskFinishedHandler)
        
        
        present(taskViewController, animated: true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let activitiesNavController = self.viewControllers?.first(where: { (viewController) -> Bool in
//            guard let navController = viewController as? UINavigationController,
//                navController.viewControllers.first is CTFActivityTableViewController else {
//                    return false
//            }
//            return true
//        }) as? UINavigationController,
//            let activitiesController = activitiesNavController.viewControllers.first as? CTFActivityTableViewController {
//            
//            if let settingsNavController = self.viewControllers?.first(where: { (viewController) -> Bool in
//                guard let navController = viewController as? UINavigationController,
//                    navController.viewControllers.first is CTFSettingsTableViewController else {
//                        return false
//                }
//                return true
//            }) as? UINavigationController,
//                let settingsController = settingsNavController.viewControllers.first as? CTFSettingsTableViewController {
//                
//                settingsController.delegate = activitiesController
//                
//                
//            }
//            
//            
//        }
        
        
    }
    
    

}
