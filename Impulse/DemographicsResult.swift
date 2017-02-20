//
//  DemographicsResult.swift
//  ImpulsivityOhmage
//
//  Created by James Kizer on 2/11/17.
//  Copyright © 2017 Foundry @ Cornell Tech. All rights reserved.
//

import UIKit
import ResearchSuiteResultsProcessor

public class DemographicsResult: RSRPIntermediateResult {
    
    //gender
    public let gender: String?
    //age
    public let age: Int?
    //zipcode
    public let zipCode: String?
    //education
    public let education: String?
    //employment
    public let employment: [String]?
    
    public init(
        gender: String?,
        age: Int?,
        zipCode: String?,
        education: String?,
        employment: [String]? ) {
        
        self.gender = gender
        self.age = age
        self.zipCode = zipCode
        self.education = education
        self.employment = employment
        
        super.init(type: "Demographics")
    }

}
