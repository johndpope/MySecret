//
//  SelectableHeaderReuseableView.swift
//  MySecret
//
//  Created by Amir lahav on 24/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

protocol SelectableHeaderReuseableView {
    var  selectBtn:UIButton? { get }
    var  currentIndexPath:IndexPath? { get }
    var  isSelected:Bool { get set }
    func update(_ indexPath:IndexPath?)

    func select(_ isSelected:Bool)
    func bind(data:MSHeaderViewableProtocol, completion:(Bool)->())
    func selectBtnAction(_ sender: UIButton)
}


protocol HeaderAlbumReuseableView {
    var  title:UILabel? { get }
}
