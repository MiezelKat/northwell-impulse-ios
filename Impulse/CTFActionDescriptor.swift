//
//  CTFActionDescriptor.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/12/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import Gloss

open class CTFActionDescriptor: Decodable {
    
    public let type: String!
    
    required public init?(json: JSON) {
    
        guard let type: String = "type" <~~ json else {
                return nil
        }
        self.type = type
        
    }

}
