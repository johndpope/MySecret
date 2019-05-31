//
//  Saveable Protocol.swift
//  MySecret
//
//  Created by Amir lahav on 02/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol Saveable:MSAssetViewableProtocol {
    var  type:MSAssetCollectionType? { get }
    var  subType:MSAssetCollectionSubtype? { get }
    var  location:CLLocation? { get }
    var  asset:PHAsset { get }
}

