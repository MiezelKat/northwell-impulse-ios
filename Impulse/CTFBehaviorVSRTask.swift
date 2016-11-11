//
//  CTFBehaviorVSRTask.swift
//  Impulse
//
//  Created by James Kizer on 11/10/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import SDLRKX
import BridgeAppSDK

let kImageWidth: CGFloat = 128.0

class CTFBehaviorVSRTask: NSObject, SBABridgeTask, SBAStepTransformer {
    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var task: PAMMultipleSelectionTask!
    var prompt: String!
    var behaviors: [ORKTextChoice]!
    var options: RKXMultipleImageSelectionSurveyOptions?
    
    
    init(dictionaryRepresentation: NSDictionary) {
        super.init()
        
        if let dict = dictionaryRepresentation as? [String: AnyObject] {
            self._taskIdentifier = dict["taskIdentifier"] as! String
            self._schemaIdentifier = dict["schemaIdentifier"] as? String
            self.prompt = dict["text"] as! String!
//            self.task = PAMMultipleSelectionTask(identifier: self._taskIdentifier, json: dictionaryRepresentation, bundle:  Bundle(for: PAMMultipleSelectionTask.self))
            if let items = dict["items"] as? [AnyObject] {
                let suffix: String = dict["valueSuffix"] as? String ?? ""
                self.behaviors = items.flatMap({ (itemDictionary) -> ORKTextChoice? in
                    guard let prompt = itemDictionary["prompt"] as? String,
                        let value = itemDictionary["value"] as? String else {
                            return nil
                    }
                    return ORKTextChoice(text: prompt, value: (value + suffix)as NSString)
                })
            }
            
            if let optionsDict = dict["options"] as? [String: AnyObject] {
                self.options = RKXMultipleImageSelectionSurveyOptions(optionsDictionary: optionsDict)
            }
        }
    }
    
    
    var taskIdentifier: String! {
        return self._taskIdentifier
    }
    
    var schemaIdentifier: String! {
        return self._schemaIdentifier
    }
    
    var taskSteps: [SBAStepTransformer] {
        return [self]
    }
    
    var insertSteps: [SBAStepTransformer]? {
        return nil
    }
    
    func transformToStep(with factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep? {
        
        let options: RKXMultipleImageSelectionSurveyOptions = {
            if let options = self.options {
                return options
            }
            else {
                let options = RKXMultipleImageSelectionSurveyOptions()
                options.somethingSelectedButtonColor = UIColor.blue
                options.nothingSelectedButtonColor = UIColor.blue
                options.itemsPerRow = 2
                options.itemMinSpacing = 4
                options.maximumSelectedNumberOfItems = 4
                return options
            }
        }()
        
//        let image = UIImage(named: "balloon")
        
        let imageChoices: [ORKImageChoice] = self.behaviors.map { (textChoice) -> ORKImageChoice in
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: kImageWidth, height: kImageWidth))
            label.numberOfLines = 0
            label.text = textChoice.choiceText
            label.textAlignment = NSTextAlignment.center
//            label.sizeToFit()
            
            UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, UIScreen.main.scale)
            label.drawHierarchy(in: label.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return ORKImageChoice(
                normalImage: image,
                selectedImage: nil,
                text: textChoice.text,
                value: textChoice.value)
        }
        
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices)
        return CTFBehaviorVSRFullAssessmentStep(identifier: self.taskIdentifier, title: self.prompt, answerFormat: answerFormat, options: options)
        
    }

}
