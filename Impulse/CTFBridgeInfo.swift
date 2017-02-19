//
//  CTFBridgeInfo.swift
//  Adapted from SBABridgeInfo.swift (see copyright below)
//  Impulse
//
//  Created by James Kizer on 2/18/17.
//  Copyright © 2017 Cornell Tech. All rights reserved.
//
//
//  SBABridgeInfo.swift
//  BridgeAppSDK
//
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import BridgeSDK

class CTFBridgeInfo: NSObject, SBBBridgeInfoProtocol {

    public var usesStandardUserDefaults: Bool {
        return true
    }


    public var studyIdentifier: String {
        return _studyIdentifier
    }
    private let _studyIdentifier: String
    
    public var cacheDaysAhead: Int = 0
    public var cacheDaysBehind: Int = 0
    public var environment: SBBEnvironment = .prod
    
    private let plist: [String: Any]
    
    public convenience override init() {
//        var plist = SBAResourceFinder.shared.plist(forResource: "BridgeInfo")!
        var plist: [String: Any] = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "BridgeInfo", ofType: "plist")!)! as! [String: Any]

        if let additionalInfo = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "BridgeInfo", ofType: "plist")!) as? [String: Any] {
            plist = plist.merge(from: additionalInfo)
        }
        let studyIdentifier = plist["studyIdentifier"] as! String
        self.init(studyIdentifier: studyIdentifier, plist: plist)
    }
    
    public init(studyIdentifier:String, plist: [String: Any]) {
        
        // Set study identifier and plist pointers
        self._studyIdentifier = studyIdentifier
        self.plist = plist
        super.init()
        
        // Setup cache days using either days ahead and behind or else using
        // default values for days ahead and behind
        let cacheDaysAhead = plist["cacheDaysAhead"] as? Int
        let cacheDaysBehind = plist["cacheDaysBehind"] as? Int
        if (cacheDaysAhead != nil) || (cacheDaysBehind != nil) {
            self.cacheDaysAhead = cacheDaysAhead ?? SBBDefaultCacheDaysAhead
            self.cacheDaysBehind = cacheDaysBehind ?? SBBDefaultCacheDaysBehind
        }
        else if let useCache = plist["useCache"] as? Bool , useCache {
            // If this plist has the useCache key then set the ahead and behind to default
            self.cacheDaysAhead = SBBDefaultCacheDaysAhead
            self.cacheDaysBehind = SBBDefaultCacheDaysBehind
        }
    }
    
//    public var appStoreLinkURLString: String? {
//        return  self.plist["appStoreLinkURL"] as? String
//    }
//    
//    public var emailForLoginViaExternalId: String? {
//        return self.plist["emailForLoginViaExternalId"] as? String
//    }
//    
//    public var passwordFormatForLoginViaExternalId: String? {
//        return self.plist["passwordFormatForLoginViaExternalId"] as? String
//    }
//    
//    public var testUserDataGroup: String? {
//        return self.plist["testUserDataGroup"] as? String
//    }
//    
//    public var taskMap: [NSDictionary]? {
//        return self.plist["taskMapping"] as? [NSDictionary]
//    }
//    
//    public var schemaMap: [NSDictionary]? {
//        return self.plist["schemaMapping"] as? [NSDictionary]
//    }
//
    public var certificateName: String? {
        return self.plist["certificateName"] as? String
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
    
}
