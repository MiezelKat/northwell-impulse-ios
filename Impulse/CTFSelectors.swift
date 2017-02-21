//
//  CTFSelectors.swift
//  Impulse
//
//  Created by James Kizer on 2/21/17.
//  Copyright © 2017 James Kizer. All rights reserved.
//

import UIKit

class CTFSelectors: NSObject {

    static func shouldShowBaselineSurvey(state: CTFReduxStore) -> Bool {
        return state.baselineCompletedDate == nil
    }
    
//    switch(scheduleItem.identifier) {
//    case "baseline":
//    return CTFStateManager.defaultManager.shouldShowBaselineSurvey()
//    
//    case "reenrollment":
//    return CTFStateManager.defaultManager.shouldShowBaselineSurvey()
//    
//    case "21-day-assessment":
//    return CTFStateManager.defaultManager.shouldShow21DaySurvey()
//    
//    case "am_survey":
//    return CTFStateManager.defaultManager.shouldShowMorningSurvey()
//    
//    case "pm_survey":
//    return CTFStateManager.defaultManager.shouldShowEveningSurvey()
//    
//    default:
//    return false
//    }


}
