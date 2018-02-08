//
//  CTFPulsusFormStep.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

open class CTFPulsusFormStep: ORKFormStep {

    open var attributedTitle: NSAttributedString?
    open var attributedText: NSAttributedString?
    
    override open func stepViewControllerClass() -> AnyClass {
        return CTFPulsusFormStepViewController.self
    }
}
