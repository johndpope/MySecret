//
//  MSLocalCollection.swift
//  MySecret
//
//  Created by Amir lahav on 04/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import RealmSwift


class MSLocalCollection: MSObject {
    
    @objc dynamic var title:String? = nil
    
    //    A Boolean value indicating whether the collection can contain assets.
    @objc dynamic var canContainAssets: Bool = false
    
    //A Boolean value indicating whether the collection can contain other collections.
    @objc dynamic var canContainCollections: Bool = false

}
