//
//  CTFActivityRunner.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/11/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ResearchKit

public class CTFTaskViewController: ORKTaskViewController, ORKTaskViewControllerDelegate {
    
    var taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ())
    
    
    init(task: ORKTask, taskFinishedHandler: @escaping ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ())) {
        
        self.taskFinishedHandler = taskFinishedHandler
        super.init(task: task, taskRun: nil)
        self.delegate = self
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        self.taskFinishedHandler(taskViewController, reason, error)
        
        
    }

}
