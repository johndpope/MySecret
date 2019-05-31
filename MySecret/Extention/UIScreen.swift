//
//  UIScreen.swift
//  MySecret
//
//  Created by Amir lahav on 27/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
extension UIScreen
{
    var deviceOrientation: UIDeviceOrientation {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            return .portrait
            
        case .faceUp, .faceDown, .portraitUpsideDown:
            // Check the interface orientation
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            switch interfaceOrientation{
            case .portrait:
                return .portrait
            default:
                return .landscapeLeft
            }
        default:
            return .landscapeLeft
        }
    }
    
    
}
