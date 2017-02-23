//
//  SBBDataArchiveConvertable.swift
//  Impulse
//
//  Created by James Kizer on 2/19/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit
import BridgeSDK

let staticISO8601Formatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale as Locale!
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter
}()


open class ArchiveableResult : NSObject {
    open let result: AnyObject
    open let filename: String
    
    init(result: AnyObject, filename: String) {
        self.result = result
        self.filename = filename
        super.init()
    }
}

public protocol SBBDataArchiveConvertable {
    func toArchive() -> SBBDataArchive?
    
    var kSchemaRevisionKey: String { get }
}

extension SBBDataArchiveConvertable {
    
    public static func ISO8601Formatter() -> DateFormatter {
        return staticISO8601Formatter
    }
    
    public func stringFromDate(_ date: Date) -> String {
        return Self.ISO8601Formatter().string(from: date)
    }

    public var kSchemaRevisionKey: String {
        return "schemaRevision"
    }
    
}
