//
//  CTFBridgeManagerError.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit

public enum CTFBridgeManagerError: Error {
    
    case alreadySignedIn
    case notSignedIn
    case accountNotFound
    case invalidSample
    
    case invalidConfig
    
}
