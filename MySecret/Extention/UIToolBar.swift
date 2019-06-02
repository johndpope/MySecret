//
//  UIToolBar.swift
//  MySecret
//
//  Created by Amir lahav on 30/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension UIToolbar
{
    func disableAll()
    {
        items?.forEach({ $0.isEnabled = false
        })
    }
    
    func enableAll()
    {
        items?.forEach({ $0.isEnabled = true
        })
    }
    
}
