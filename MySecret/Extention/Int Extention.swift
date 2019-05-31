//
//  Int Extention.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation


extension Int{
    
    var boolValue: Bool { return self != 0 }

    
    func toString() -> String
    {
        switch self {
        case 0:
            return "Select Items"
        case 1:
            return "1 Item Selected"
        default:
            return "\(self) Items Selected"
        }
    }
    
}

