//
//  UIColor+String.swift
//  Impulse
//
//  Created by James Kizer on 11/16/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Foundation

extension UIColor {
    // Assumes input like "#00FF00" (#RRGGBB).
    convenience init?(hexString: String) {
        
        //check that input is valid
        let validationRegex = try! NSRegularExpression(pattern: "^#[0-9,a-f]{6}$", options: [NSRegularExpression.Options.caseInsensitive])
        guard validationRegex.matches(in: hexString, options: [], range: NSRange(location: 0, length: hexString.characters.count)).count == 1 else {
            return nil
        }
        
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 1
        var x: UInt32 = 0
        
        guard scanner.scanHexInt32(&x) else {
            return nil
        }
        
        let red: CGFloat = CGFloat((x & 0xFF0000) >> 16)/255.0
        let green: CGFloat = CGFloat((x & 0xFF00) >> 8)/255.0
        let blue: CGFloat = CGFloat(x & 0xFF)/255.0
        self.init(red: red, green: green, blue: blue, alpha:1.0)
    }
}
