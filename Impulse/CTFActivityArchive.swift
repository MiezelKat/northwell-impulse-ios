//
//  CTFActivityArchive.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/27/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import Foundation
import BridgeAppSDK

private let kSurveyCreatedOnKey               = "surveyCreatedOn"
private let kSurveyGuidKey                    = "surveyGuid"
private let kSchemaRevisionKey                = "schemaRevision"
private let kTaskIdentifierKey                = "taskIdentifier"
private let kScheduledActivityGuidKey         = "scheduledActivityGuid"
private let kTaskRunUUIDKey                   = "taskRunUUID"
private let kStartDate                        = "startDate"
private let kEndDate                          = "endDate"
private let kMetadataFilename                 = "metadata.json"

class CTFActivityArchive: SBADataArchive {
    
    fileprivate var metadata = [String: AnyObject]()
    
    init?(result: SBAActivityResult, jsonValidationMapping: [String: NSPredicate]? = nil) {
        super.init(reference: result.schemaIdentifier, jsonValidationMapping: jsonValidationMapping)
        
        // set up the activity metadata
        // -- always set scheduledActivityGuid and taskRunUUID
        self.metadata[kScheduledActivityGuidKey] = result.schedule.guid as AnyObject?
        self.metadata[kTaskRunUUIDKey] = result.taskRunUUID.uuidString as AnyObject?
        
        // -- if it's a task, also set the taskIdentifier
        if let taskReference = result.schedule.activity.task {
            self.metadata[kTaskIdentifierKey] = taskReference.identifier as AnyObject?
        }
        
        // -- add the start/end date
        self.metadata[kStartDate] = (result.startDate as NSDate).iso8601String() as AnyObject?
        self.metadata[kEndDate] = (result.endDate as NSDate).iso8601String() as AnyObject?
        
        // set up the info.json
        // -- always set the schemaRevision
        self.setArchiveInfoObject(result.schemaRevision, forKey: kSchemaRevisionKey)
        
        // -- if it's a survey, also set the survey's guid and createdOn
        if let surveyReference = result.schedule.activity.survey {
            // Survey schema is better matched by created date and survey guid
            self.setArchiveInfoObject(surveyReference.guid as SBAJSONObject, forKey: kSurveyGuidKey)
            let createdOn = surveyReference.createdOn ?? NSDate() as Date
            self.setArchiveInfoObject((createdOn as NSDate).iso8601String() as SBAJSONObject, forKey: kSurveyCreatedOnKey)
        }
        
        if !self.buildArchiveForResult(result) {
            self.remove()
            return nil
        }
    }
    
    func buildArchiveForResult(_ activityResult: SBAActivityResult) -> Bool {
        
        // exit early with false if nothing to archive
        guard let activityResultResults = activityResult.results as? [ORKStepResult]
            , activityResultResults.count > 0
            else {
                return false
        }
        
        // (although there _still_ might be nothing to archive, if none of the stepResults have any results.)
        for stepResult in activityResultResults {
            if let stepResultResults = stepResult.results {
                for result in stepResultResults {
                    if !insertResult(result, stepResult: stepResult, activityResult: activityResult) {
                        return false
                    }
                }
            }
        }
        
        // don't insert the metadata if the archive is otherwise empty
        let builtArchive = !isEmpty()
        if builtArchive {
            insertDictionary(intoArchive: self.metadata, filename: kMetadataFilename)
        }
        
        return builtArchive
    }
    
    /**
     * Method for inserting a result into an archive. Allows for override by subclasses
     */
    func insertResult(_ result: ORKResult, stepResult: ORKStepResult, activityResult: SBAActivityResult) -> Bool {
        
        guard let archiveableResult = result.bridgeData(stepResult.identifier) else {
            assertionFailure("Something went wrong getting result to archive from result \(result.identifier) of step \(stepResult.identifier) of activity result \(activityResult.identifier)")
            return false
        }
        
        if let urlResult = archiveableResult.result as? NSURL {
            self.insertURL(intoArchive: urlResult as URL, fileName: archiveableResult.filename)
        } else if let dictResult = archiveableResult.result as? [AnyHashable: Any] {
            self.insertDictionary(intoArchive: dictResult, filename: archiveableResult.filename)
        } else if let dataResult = archiveableResult.result as? NSData {
            self.insertData(intoArchive: dataResult as Data, filename: archiveableResult.filename)
        } else {
            let className = NSStringFromClass(archiveableResult.result.classForCoder)
            assertionFailure("Unsupported archiveable result type: \(className)")
            return false
        }
        
        return true
    }
    

}
