//
//  CellConfigurator.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class CollectionCellConfigurator<CellType: ConfigurableCell, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UICollectionViewCell {
    
    typealias source = DataType
    static var reuseId: String { return NSStringFromClass(CellType.self) }
    
    let item: DataType
    
    required init(item: DataType) {
        self.item = item
    }
    
    func configure(cell: UIView, completion:@escaping(Bool)->()) {
        guard let cell = cell as? CellType else {
            return
        }
        cell.bind(data: item, completion: completion)
    }
}

class CollectionHeaderConfigurator<HeaderType: ConfigurableCell, DataType>: HeaderConfigurator where HeaderType.DataType == DataType, HeaderType: UICollectionReusableView {
    
    static var reuseId: String { return NSStringFromClass(HeaderType.self) }
    
    let item: DataType
    
    init(item: DataType) {
        self.item = item
    }
    
    func configure(header: UIView, completion:@escaping(Bool)->()) {
        guard let header = header as? HeaderType else {
            return
        }
        header.bind(data: item, completion: completion)
    }
}
