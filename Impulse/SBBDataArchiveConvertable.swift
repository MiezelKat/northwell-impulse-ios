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
    
//    static var kSurveyCreatedOnKey: String { get }
//    static var kSurveyGuidKey: String { get }
    var kSchemaRevisionKey: String { get }
//    static var kTaskIdentifierKey: String { get }
//    static var kScheduledActivityGuidKey: String { get }
//    static var kTaskRunUUIDKey: String { get }
    var kStartDate: String { get }
    var kEndDate: String { get }
//    static var kMetadataFilename: String { get }
}





extension SBBDataArchiveConvertable {
    //    func kSurveyCreatedOnKey() -> String
    
    public static func ISO8601Formatter() -> DateFormatter {
        return staticISO8601Formatter
    }
    
    public func stringFromDate(_ date: Date) -> String {
        return Self.ISO8601Formatter().string(from: date)
    }
    
    public static var kSurveyCreatedOnKey: String {
        return "surveyCreatedOn"
    }
    
    public static var kSurveyGuidKey: String {
        return "surveyGuid"
    }
    
    public var kSchemaRevisionKey: String {
        return "schemaRevision"
    }
    
    public static var kTaskIdentifierKey: String {
        return "taskIdentifier"
    }
    
    public static var kScheduledActivityGuidKey: String {
        return "scheduledActivityGuid"
    }
    
    public static var kTaskRunUUIDKey: String {
        return "taskRunUUID"
    }
    
    public var kStartDate: String {
        return "startDate"
    }

    public var kEndDate: String {
        return "endDate"
    }
    
    public static var kMetadataFilename: String {
        return "metadata.json"
    }
    
}
