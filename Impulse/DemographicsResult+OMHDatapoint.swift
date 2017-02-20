//
//  DemographicsResult+OMHDatapoint.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/11/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

//import OMHClient
//
//extension DemographicsResult: OMHDataPointBuilder {
//    
//    open var creationDateTime: Date {
//        return self.startDate ?? Date()
//    }
//    
//    open var dataPointID: String {
//        return self.uuid.uuidString
//    }
//    
//    open var acquisitionModality: OMHAcquisitionProvenanceModality? {
//        return .SelfReported
//    }
//    
//    open var acquisitionSourceCreationDateTime: Date? {
//        return self.startDate
//    }
//    
//    open var acquisitionSourceName: String? {
//        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
//    }
//    
//    open var schema: OMHSchema {
//        return OMHSchema(name: "SampleDemographics", version: "1.0", namespace: "Cornell")
//    }
//    
//    open var body: [String: Any] {
//        var returnBody: [String: Any] = [:]
//        
//        returnBody["gender"] = self.gender
//        returnBody["age"] = self.age
//        returnBody["zip_code"] = self.zipCode
//        returnBody["education"] = self.education
//        returnBody["employment"] = self.employment
//        
//        return returnBody
//        
//    }
//    
//}

