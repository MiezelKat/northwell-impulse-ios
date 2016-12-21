//
//  CTFSemanticDifferentialScaleFormParameters.swift
//  Impulse
//
//  Created by James Kizer on 12/19/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import UIKit
import Gloss

class CTFSemanticDifferentialScaleFormParameters: Decodable {
    
    let text: String?
    let title: String?
    let items: [CTFSemanticDifferentialScaleFormItemDecriptor]!
    
    required public init?(json: JSON) {
        
        guard let items: [CTFSemanticDifferentialScaleFormItemDecriptor] = "items" <~~ json else {
            return nil
        }
        
        self.items = items
        self.text = "text" <~~ json
        self.title = "title" <~~ json
        
    }

}
