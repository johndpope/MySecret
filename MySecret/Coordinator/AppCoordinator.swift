//
//  AppCoordinator.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator:Coordinator
{    
    var image: UIImage? = nil
    
    var window:UIWindow
    var pressenter: UINavigationController
    var loginCoordinator:LogInCoordinator
    
    init(window:UIWindow) {
        
        self.window = window
        
        // setup container
        pressenter = UINavigationController()
        pressenter.navigationBar.isHidden = true
        
        /// test contoller
        let test = UIViewController()
        test.view.backgroundColor = .brown
        pressenter.pushViewController(test, animated: false)
        
        loginCoordinator = LogInCoordinator(pressenter: pressenter)
        
    }
    
    
    func start() {
        
        self.window.rootViewController = pressenter
        
        loginCoordinator.start()
        
        self.window.makeKeyAndVisible()
    }
    
    
    
    
    
}
