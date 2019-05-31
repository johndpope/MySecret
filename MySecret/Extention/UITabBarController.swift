//
//  UITabBarController.swift
//  MySecret
//
//  Created by Amir lahav on 28/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension UITabBarController {
    
    func setTabBarHidden(_ isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil ) {
        if (tabBar.isHidden == isHidden) {
            completion?()
        }
        
        if !isHidden {
            tabBar.isHidden = false
        }
        
        let height:CGFloat = 10
        let offsetY = view.frame.height - tabBar.frame.height + (isHidden ? 0 : height)
        
        
        let duration = (animated ? 0.25 : 0.0)
        
        let frame = CGRect(x:  tabBar.frame.minX, y: tabBar.frame.minY, width:tabBar.frame.width, height:tabBar.frame.height)
        UIView.animate(withDuration: duration, animations: {
            self.tabBar.frame = frame
            self.tabBar.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    

}
