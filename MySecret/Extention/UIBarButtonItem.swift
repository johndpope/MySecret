//
//  UIBarButtonItem.swift
//  MySecret
//
//  Created by Amir lahav on 08/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem{
    
    
    func with(itemType:UIBarButtonItemType,target:Any?, action:Selector?) -> UIBarButtonItem
    {
        switch itemType {
        case .back:
            let button =  UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: target, action: action)
            button.imageInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
            button.landscapeImagePhoneInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            return button
        }

    }
    
}


enum UIBarButtonItemType
{
    case back
}
