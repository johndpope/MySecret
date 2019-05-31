//
//  UICollectionReusableView Extention.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionReusableView: ReusableView,Xibable {
    
}

class CollectionViewHeader: UICollectionReusableView {
    weak var delegate:GridSectionHeaderViewProtocol?

}
