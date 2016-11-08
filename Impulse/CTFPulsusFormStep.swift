//
//  CTFPulsusFormStep.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

class CTFPulsusFormStep: ORKFormStep {

    override func stepViewControllerClass() -> AnyClass {
        return CTFPulsusFormStepViewController.self
    }
}
