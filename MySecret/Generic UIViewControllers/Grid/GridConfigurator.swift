//
//  GridConfigurator.swift
//  MySecret
//
//  Created by Amir lahav on 08/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
struct GridConfigurator {
    
    let displayMode:UINavigationItem.LargeTitleDisplayMode
    let canManualAppendAssets:Bool
    let hideToolbarBackground:Bool
    init() {
        displayMode = .automatic
        canManualAppendAssets = false
        hideToolbarBackground = false
    }
    
    init(displayMode:UINavigationItem.LargeTitleDisplayMode, canManualAppendAssets:Bool, hideToolbarBackground:Bool = false) {
        self.displayMode = displayMode
        self.canManualAppendAssets = canManualAppendAssets
        self.hideToolbarBackground = hideToolbarBackground
    }
}
