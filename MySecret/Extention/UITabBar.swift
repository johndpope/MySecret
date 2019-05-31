//
//  UITabBar.swift
//  MySecret
//
//  Created by Amir lahav on 28/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar
{
    func setClear()
    {
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        self.clipsToBounds = true
        
    }
}

extension UIToolbar
{
    func setClear()
    {
        self.setBackgroundImage(UIImage(),
                                        forToolbarPosition: .any,
                                        barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        
    }
}
