//
//  LogInCoordinator.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

final class LogInCoordinator:Coordinator
{
    var image: UIImage? = nil
    
    var pressenter: UINavigationController
    var rootViewController:LoginViewController?
    var tabCoordinator:TabMangerCoordinator?
    
    init(pressenter:UINavigationController) {
        self.pressenter = pressenter
    }
    
    func start() {
        let logIn = LoginViewController()
        logIn.loggedIn = loggedIn
        pressenter.pushViewController(logIn, animated: false)
        rootViewController = logIn
    }
    
    
    func loggedIn(){
        
        let tc = TabMangerCoordinator(pressenter: pressenter)
        tc.start()
    }
    
    
}
