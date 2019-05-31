//
//  MSAssetViewable Protocol.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit
import RealmSwift
import CoreLocation

protocol MSAssetViewableProtocol{
    
    var localIdentifier:String { get }
    var asstetType:MSAssetMediaType { get }
    var isFavorite:Bool { get }
    var creationDate:Date { get }
    var duration:Double { get }
    var isNSFW:Bool { get }
    var hasFace:Bool { get }
    var locationDesc:String { get }
    var canDelete:Bool { get set }
    func loadImageWithCompletionHandler(targetSize:CellTargetSize, imageQuality:ImageQuality ,completion: @escaping (UIImage?, Error?) -> ())
    func canacelLoading()

}



extension MSAssetViewableProtocol {
    var canDelete:Bool {
        return false
    }
}
