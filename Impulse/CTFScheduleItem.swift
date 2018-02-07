//
//  CTFScheduleItem.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 1/29/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import Gloss
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor

class CTFScheduleItem: Gloss.Decodable {
    
    public let type: String!
    public let identifier: String!
    public let title: String!
    public let guid: String!
    
    public let activity: JSON!
    public let resultTransforms: [RSRPResultTransform]
    public let onCompletionActions: [CTFActionDescriptor]
    
    // MARK: - Deserialization
    
    required public init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            let identifier: String = "identifier" <~~ json,
            let title: String = "title" <~~ json,
            let guid: String = "guid" <~~ json,
            let activity: JSON = "activity" <~~ json else {
                return nil
        }
        self.type = type
        self.identifier = identifier
        self.title = title
        self.guid = guid
        
        self.activity = activity
        self.resultTransforms = {
            guard let resultTransforms: [JSON] = "resultTransforms" <~~ json else {
                return []
            }
            
            return resultTransforms.flatMap({ (transform) -> RSRPResultTransform? in
                return RSRPResultTransform(json: transform)
            })
        }()
        
        
        self.onCompletionActions = {
            guard let actions: [JSON] = "onCompletionActions" <~~ json else {
                return []
            }
            
            return actions.flatMap({ (json) -> CTFActionDescriptor? in
                return CTFActionDescriptor(json: json)
            })
        }()
        
        
        
        
    }

}
