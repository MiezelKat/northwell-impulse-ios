//
//  CTFPAMTask.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK
import SDLRKX

@objc class CTFPAMTask: NSObject, SBABridgeTask, SBAStepTransformer {
    
    // MARK: SBABridgeTask
    
    let task: PAMMultipleSelectionTask
    init(dictionaryRepresentation: NSDictionary) {
        self.task = PAMMultipleSelectionTask(identifier: "testIdentifier", json: dictionaryRepresentation, bundle:  Bundle(for: PAMMultipleSelectionTask.self))
//        self.task = PAMMultipleSelectionTask(identifier: "testIdentifier")
        super.init()
    }
    
    
    var taskIdentifier: String! {
        return "PAM"
    }
    
    var schemaIdentifier: String! {
        return "1"
    }
    
    var taskSteps: [SBAStepTransformer] {
        return [self]
    }
    
    var insertSteps: [SBAStepTransformer]? {
        return nil
    }
    
//    func initWithDictionaryRepresentation(dictionary: NSDictionary) {
//        
//    }

    
    // MARK: SBAStepTransformer
    
//    func transformToTaskAndIncludes(factory: SBASurveyFactory, isLastStep: Bool) -> (task: SBANavigableOrderedTask?, include: SBATrackingStepIncludes?)  {
//        
//        // Check the dataStore to determine if the momentInDay id map has been setup and do so if needed
//        if (self.dataStore.momentInDayResultDefaultIdMap == nil) {
//            self.dataStore.updateMomentInDayIdMap(filteredSteps(.ActivityOnly, factory: factory))
//        }
//        
//        // Build the approproate steps
//        
//        var include: SBATrackingStepIncludes = .None
//        if (isLastStep) {
//            // If this is the last step then it is not being inserted into another task activity
//            include = .StandAloneSurvey
//        }
//        else if (!self.dataStore.hasSelectedOrSkipped) {
//            include = .SurveyAndActivity
//        }
//        else if (self.shouldShowChangedStep()) {
//            if (self.dataStore.hasNoTrackedItems) {
//                include = .ChangedOnly
//            }
//            else {
//                include = .ChangedAndActivity
//            }
//        }
//        else if (self.dataStore.shouldIncludeMomentInDayStep ||
//            (self.alwaysIncludeActivitySteps && !self.dataStore.hasNoTrackedItems)) {
//            include = .ActivityOnly
//        }
//        
//        let steps = filteredSteps(include, factory: factory)
//        let task = SBANavigableOrderedTask(identifier: self.schemaIdentifier, steps: steps)
//        task.conditionalRule = self
//        
//        return (task, include)
//    }
    
    func transformToStep(with factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep? {
        return self.task.steps[0]
//        let (retTask, retInclude) = transformToTaskAndIncludes(factory, isLastStep: isLastStep)
//        guard let task = retTask, let include = retInclude else { return nil }
//        
//        let subtaskStep = SBASubtaskStep(subtask: task)
//        if (include.includeSurvey()) {
//            // Only set the task and schema identifier if the full survey is included
//            subtaskStep.taskIdentifier = self.taskIdentifier
//            subtaskStep.schemaIdentifier = self.schemaIdentifier
//        }
//        
//        return subtaskStep
    }
    
}
