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

            if let vc = self.presentedViewController {
                vc.view.isHidden = contentHidden
            }
            
            self.view.isHidden = contentHidden
        }
    }
    
    var store: Store<CTFReduxState>? {
        if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
            return appDelegate.reduxStoreManager?.store
        }
        else {
            return nil
        }
    }
    
    var taskBuilder: CTFTaskBuilderManager? {
        if let appDelegate = UIApplication.shared.delegate as? CTFAppDelegate {
            return appDelegate.taskBuilderManager
        }
        else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.store?.subscribe(self)
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    func newState(state: CTFReduxState) {
        
        if self.presentedActivity == nil,
            let (uuid, activityRun) = state.activityQueue.first {
            
            self.presentedActivity = uuid
            self.runActivity(uuid: uuid, activityRun: activityRun)
            
        }
        
        debugPrint(CTFSelectors.getValueInExtensibleStorage(state)("BaselineBehaviorResults"))
        
    }
    
    func runActivity(uuid: UUID, activityRun: CTFActivityRun) {
        
        guard let steps = self.taskBuilder?.rstb.steps(forElement: activityRun.activity) else {
            return
        }
        
        
        
        let task = ORKOrderedTask(identifier: activityRun.identifier, steps: steps)
        
        let store = self.store
        
        let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { [weak self] (taskViewController, reason, error) in
            
            let taskResult: ORKTaskResult? = (reason == ORKTaskViewControllerFinishReason.completed) ?
                taskViewController.result : nil
            
            store?.dispatch(CTFActionCreators.completeActivity(uuid: uuid, activityRun: activityRun, taskResult: taskResult), callback: { (state) in
                
                self?.dismiss(animated: true, completion: {
                    self?.presentedActivity = nil
                })
            })
            
            
            
        }
        
        let taskViewController = CTFTaskViewController(activityUUID: uuid, task: task, taskFinishedHandler: taskFinishedHandler)
        
        
        present(taskViewController, animated: true, completion: nil)
        
    }
    

}
