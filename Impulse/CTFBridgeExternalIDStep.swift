//
//  CTFBridgeExternalIDStep.swift
//  Impulse
//
//  Created by James Kizer on 2/18/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import ResearchKit

class CTFBridgeExternalIDStep: CTFLoginStep {

    public init(identifier: String) {
        
        super.init(identifier: identifier,
                   title: "Sign In",
                   text: "Please enter your participant ID",
                   identityFieldName: "Participant ID",
                   identityFieldAnswerFormat: CTFLoginStep.usernameAnswerFormat(),
                   passwordFieldName: "Confirm Participant ID",
                   passwordFieldAnswerFormat: CTFLoginStep.usernameAnswerFormat(),
                   loginViewControllerClass: CTFBridgeExternalIDStepViewController.self,
                   loginButtonTitle: "Sign In",
                   forgotPasswordButtonTitle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
