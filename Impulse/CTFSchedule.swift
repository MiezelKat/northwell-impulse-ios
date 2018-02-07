//
//  CTFSchedule.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 1/29/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import Gloss

class CTFSchedule: Gloss.Decodable {
    
    public let type: String!
    public let identifier: String!
    public let title: String!
    public let guid: String!
    
    public let items: [CTFScheduleItem]!
    
    // MARK: - Deserialization
    
    required public init?(json: JSON) {

        guard let type: String = "type" <~~ json,
            let identifier: String = "identifier" <~~ json,
            let title: String = "title" <~~ json,
            let guid: String = "guid" <~~ json,
            let items: [JSON] = "items" <~~ json else {
                return nil
        }
        self.type = type
        self.identifier = identifier
        self.title = title
        self.guid = guid
        
        self.items = items.flatMap { (json) -> CTFScheduleItem? in
            
            return CTFScheduleItem(json: json)
            
        }
        
    }

}
