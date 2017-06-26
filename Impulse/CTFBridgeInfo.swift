//
//  CTFBridgeInfo.swift
//  Impulse
//
//  Created by James Kizer on 6/26/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import BridgeSDK

open class CTFBridgeInfo: NSObject, SBBBridgeInfoProtocol {
    /**
     Study identifier used to setup the study with Bridge
     */
    public var studyIdentifier: String {
        return self.bridgeInfoDict["studyIdentifier"] as! String
    }
    
    
    /**
     Name of .pem certificate file to use for uploading to Bridge (without the .pem extension)
     */
    public var certificateName: String? {
        return self.bridgeInfoDict["certificateName"] as? String
    }
    
    
    /**
     If using BridgeSDK's built-in caching, number of days ahead to cache.
     Set both this and cacheDaysBehind to 0 to disable caching in BridgeSDK.
     */
    public var cacheDaysAhead: Int {
        return 0
    }
    
    
    /**
     If using BridgeSDK's built-in caching, number of days behind to cache.
     Set both this and cacheDaysAhead to 0 to disable caching in BridgeSDK.
     */
    public var cacheDaysBehind: Int {
        return 0
    }
    
    
    /**
     Server environment to use.
     Generally you should not set this to anything other than SBBEnvironmentProd unless you are running your own
     Bridge server, and then only to test changes to the server which you have not yet deployed to production.
     */
    public var environment: SBBEnvironment {
        return .prod
    }
    
    
    /**
     Tells the Bridge libraries to use the standard user defaults suite.
     
     @note This flag is intended only for backward compatibility when upgrading apps built with older versions of Bridge libraries that used the standard user defaults suite. It will be ignored in any case if either userDefaultsSuiteName or appGroupIdentifier are set.
     */
    public var usesStandardUserDefaults: Bool {
        return false
    }
    
    
    /**
     The name of the user defaults suite for the Bridge libraries to use internally. Only needs to be set if you want
     the Bridge libraries to use something other than their default internal suite name (org.sagebase.Bridge)
     or, in conjunction with appGroupIdentifier, to have them use a different suite other than the
     shared suite.
     */
    public var userDefaultsSuiteName: String? {
        return nil
    }
    
    
    /**
     This property, if set, is used for the suite name of NSUserDefaults (if userDefaultsSuiteName
     is not explicitly set), and for the name of the shared container, which is used both to configure the
     background session and as the place to store temporary copies of files being uploaded to Bridge
     (if provided).
     */
    public var appGroupIdentifier: String? {
        return nil
    }
    
    public var emailForLoginViaExternalId: String? {
        return self.bridgeInfoDict["emailForLoginViaExternalId"] as? String
    }
    
    private let bridgeInfoDict: [String: AnyObject]
    
    public init(bridgeInfoDict: [String: AnyObject]) {
        self.bridgeInfoDict = bridgeInfoDict
    }
}
