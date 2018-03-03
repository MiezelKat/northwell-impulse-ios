//
//  DMTEmailStepGenerator.swift
//  Impulse
//
//  Created by James Kizer on 2/14/18.
//  Copyright © 2018 James Kizer. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions
import ResearchSuiteTaskBuilder
import Gloss

open class DMTEmailStepGenerator: RSEmailStepGenerator {
    
    override open var supportedTypes: [String]! {
        return ["DMTEmailStep"]
    }
    
    let both: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    let letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let numbers: [Character] = Array("0123456789")
    
    func randomStringWithLength(len: Int, alphabet: [Character]) -> String {
        let chars: [Character] = (0..<len).flatMap { _ in return alphabet.random() }
        return String(chars)
    }
    
    
    open override func generateMessageBody(type: String, jsonObject: JSON, helper: RSTBTaskBuilderHelper) -> String? {
        return "Completion Code: DMT-\(self.randomStringWithLength(len: 6, alphabet: numbers))-\(self.randomStringWithLength(len: 2, alphabet: letters))"
    }
    
}
