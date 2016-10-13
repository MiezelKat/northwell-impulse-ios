//
//  ORKStepViewController+Helpers.swift
//  Impulse
//
//  Created by James Kizer on 10/12/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Foundation
import ResearchKit

extension ORKStepViewController {
    func previousStepResult(stepIdentifier: String) -> ORKStepResult? {
        
        guard self.hasPreviousStep(),
            let currentStep = self.step,
            let taskVC = self.taskViewController,
            let task = taskVC.task,
            let previousStep = task.step(before: currentStep, with: taskVC.result)
            else {
                
                return nil
        }
        
        return taskVC.result.stepResult(forStepIdentifier: previousStep.identifier)
        
    }
}
