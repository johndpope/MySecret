//
//  UINavigationController Extention.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController
{
    func push(vc:UIViewController, type:CATransitionType, subType:CATransitionSubtype? = nil)
    {
        let transition:CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        transition.subtype = subType
        self.view.layer.add(transition, forKey: kCATransition)
        self.pushViewController(vc, animated: false)
    }
    
    func pop(type:CATransitionType, subType:CATransitionSubtype? = nil)
    {
        let transition:CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        transition.subtype = subType
        self.view.layer.add(transition, forKey: kCATransition)
        self.popViewController(animated: false)
    }
    
    
}
