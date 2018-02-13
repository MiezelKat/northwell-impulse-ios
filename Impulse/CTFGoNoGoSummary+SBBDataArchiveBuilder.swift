//
//  CTFGoNoGoSummary+SBBDataArchiveBuilder.swift
//  Impulse
//
//  Created by James Kizer on 3/2/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import Foundation
import sdlrkx
import BridgeSDK

extension CTFGoNoGoSummary {

    //its up to this convertable to manage the schema id and schema revision
    override public var schemaIdentifier: String {
        return "goNoGo_v2"
    }

    override public var schemaVersion: Int {
        return 1
    }

    //note that this a work around for the swift dictionary literal compiler bug
    public func dataDictionary() -> [String:Any] {

        var bodyDictionary: [String: Any] = [:]

        bodyDictionary["variable_label"] = self.variableLabel
        bodyDictionary["number_of_trials"] = self.numberOfTrials

        bodyDictionary["number_of_correct_responses"] = self.totalSummary.numberOfCorrectResponses
        bodyDictionary["number_of_correct_responses_first_third"] = self.firstThirdSummary.numberOfCorrectResponses
        bodyDictionary["number_of_correct_responses_second_third"] = self.middleThirdSummary.numberOfCorrectResponses
        bodyDictionary["number_of_correct_responses_last_third"] = self.lastThirdSummary.numberOfCorrectResponses

        bodyDictionary["number_of_correct_nonresponses"] = self.totalSummary.numberOfCorrectNonresponses
        bodyDictionary["number_of_correct_nonresponses_first_third"] = self.firstThirdSummary.numberOfCorrectNonresponses
        bodyDictionary["number_of_correct_nonresponses_second_third"] = self.middleThirdSummary.numberOfCorrectNonresponses
        bodyDictionary["number_of_correct_nonresponses_last_third"] = self.lastThirdSummary.numberOfCorrectNonresponses

        bodyDictionary["number_of_incorrect_responses"] = self.totalSummary.numberOfIncorrectResponses
        bodyDictionary["number_of_incorrect_responses_first_third"] = self.firstThirdSummary.numberOfIncorrectResponses
        bodyDictionary["number_of_incorrect_responses_second_third"] = self.middleThirdSummary.numberOfIncorrectResponses
        bodyDictionary["number_of_incorrect_responses_last_third"] = self.lastThirdSummary.numberOfIncorrectResponses

        bodyDictionary["number_of_incorrect_nonresponses"] = self.totalSummary.numberOfIncorrectNonresponses
        bodyDictionary["number_of_incorrect_nonresponses_first_third"] = self.firstThirdSummary.numberOfIncorrectNonresponses
        bodyDictionary["number_of_incorrect_nonresponses_second_third"] = self.middleThirdSummary.numberOfIncorrectNonresponses
        bodyDictionary["number_of_incorrect_nonresponses_last_third"] = self.lastThirdSummary.numberOfIncorrectNonresponses
        
        bodyDictionary["response_time_mean"] = self.totalSummary.responseTimeMean
        bodyDictionary["response_time_mean_first_third"] = self.firstThirdSummary.responseTimeMean
        bodyDictionary["response_time_mean_second_third"] = self.middleThirdSummary.responseTimeMean
        bodyDictionary["response_time_mean_last_third"] = self.lastThirdSummary.responseTimeMean
        
        bodyDictionary["response_time_range"] = self.totalSummary.responseTimeRange
        bodyDictionary["response_time_range_first_third"] = self.firstThirdSummary.responseTimeRange
        bodyDictionary["response_time_range_second_third"] = self.middleThirdSummary.responseTimeRange
        bodyDictionary["response_time_range_last_third"] = self.lastThirdSummary.responseTimeRange
        
        bodyDictionary["response_time_std_dev"] = self.totalSummary.responseTimeStdDev
        bodyDictionary["response_time_std_dev_first_third"] = self.firstThirdSummary.responseTimeStdDev
        bodyDictionary["response_time_std_dev_second_third"] = self.middleThirdSummary.responseTimeStdDev
        bodyDictionary["response_time_std_dev_last_third"] = self.lastThirdSummary.responseTimeStdDev
        
        bodyDictionary["response_time_mean_after_one_incorrect"] = self.totalSummary.meanResponseTimeAfterOneIncorrect
        bodyDictionary["response_time_mean_after_one_incorrect_first_third"] = self.firstThirdSummary.meanResponseTimeAfterOneIncorrect
        bodyDictionary["response_time_mean_after_one_incorrect_second_third"] = self.middleThirdSummary.meanResponseTimeAfterOneIncorrect
        bodyDictionary["response_time_mean_after_one_incorrect_last_third"] = self.lastThirdSummary.meanResponseTimeAfterOneIncorrect
        
        bodyDictionary["response_time_mean_after_ten_correct"] = self.totalSummary.meanResponseTimeAfterTenCorrect
        bodyDictionary["response_time_mean_after_ten_correct_first_third"] = self.firstThirdSummary.meanResponseTimeAfterTenCorrect
        bodyDictionary["response_time_mean_after_ten_correct_second_third"] = self.middleThirdSummary.meanResponseTimeAfterTenCorrect
        bodyDictionary["response_time_mean_after_ten_correct_last_third"] = self.lastThirdSummary.meanResponseTimeAfterTenCorrect
        
        bodyDictionary["response_time_mean_correct"] = self.totalSummary.meanResponseTimeCorrect
        bodyDictionary["response_time_mean_correct_first_third"] = self.firstThirdSummary.meanResponseTimeCorrect
        bodyDictionary["response_time_mean_correct_second_third"] = self.middleThirdSummary.meanResponseTimeCorrect
        bodyDictionary["response_time_mean_correct_last_third"] = self.lastThirdSummary.meanResponseTimeCorrect
        
        bodyDictionary["response_time_mean_incorrect"] = self.totalSummary.meanResponseTimeIncorrect
        bodyDictionary["response_time_mean_incorrect_first_third"] = self.firstThirdSummary.meanResponseTimeIncorrect
        bodyDictionary["response_time_mean_incorrect_second_third"] = self.middleThirdSummary.meanResponseTimeIncorrect
        bodyDictionary["response_time_mean_incorrect_last_third"] = self.lastThirdSummary.meanResponseTimeIncorrect
        
        return bodyDictionary
    }

    override public var data: [String: Any] {
        return self.dataDictionary()
    }

}
