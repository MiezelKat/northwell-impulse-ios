//
//  CTFLikertScaleFormParameters.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import Gloss

class CTFLikertScaleFormParameters: Gloss.Decodable {

    let text: String?
    let title: String?
    let items: [CTFLikertFormItemDescriptor]!
    
    required public init?(json: JSON) {
        
        guard let items: [CTFLikertFormItemDescriptor] = "items" <~~ json else {
            return nil
        }
        
        self.items = items
        self.text = "text" <~~ json
        self.title = "title" <~~ json
        
    }
    
}
