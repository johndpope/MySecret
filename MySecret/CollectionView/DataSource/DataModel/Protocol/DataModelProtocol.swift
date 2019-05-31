//
//  DataModelProtocol.swift
//  MySecret
//
//  Created by Amir lahav on 27/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

protocol DataModelProtocol {
    
    associatedtype Model: MSAssetViewableProtocol & Differentiable    
    func fetchData(completion:(Result<[Model]>)->())
}
