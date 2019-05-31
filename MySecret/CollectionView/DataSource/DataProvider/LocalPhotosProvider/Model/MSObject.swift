//
//  MSAsset.swift
//  MySecret
//
//  Created by Amir lahav on 02/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import RealmSwift
import DifferenceKit

class MSObject: Object, Differentiable {
    
    @objc dynamic var localIdentifier:String = ""
    
    override static func primaryKey() -> String? {
        return "localIdentifier"
    }
    
    var differenceIdentifier: Int {
        return (localIdentifier as NSString).integerValue
    }
    
    func isContentEqual(to source: MSLocalAsset) -> Bool {
        return localIdentifier == source.localIdentifier
    }
}
