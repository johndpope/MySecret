//
//  CellConfigurator Protocol.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

protocol ConfigurableCell {
    associatedtype DataType
    func bind(data: DataType, completion:@escaping(Bool)->())
}

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView,completion:@escaping(Bool)->())
    
}

protocol HeaderConfigurator {
    static var reuseId: String { get }
    func configure(header: UIView, completion:@escaping(Bool)->())
}
