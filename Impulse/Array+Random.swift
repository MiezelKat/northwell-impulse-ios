//
//  Array+Random.swift
//  Impulse
//
//  Created by James Kizer on 10/13/16.
//  Copyright © 2016 James Kizer. All rights reserved.
//

import Foundation

extension Array {
    func random() -> Element? {
        if self.count == 0 {
            return nil
        }
        else{
            let index = Int(arc4random_uniform(UInt32(self.count)))
            return self[index]
        }
    }
}
