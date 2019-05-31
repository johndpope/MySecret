//
//  TabCCoordinator.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class TabMangerCoordinator: Coordinator {
    
    var image: UIImage? = nil        
    var pressenter: UINavigationController
    var rootViewController:UITabBarController?
    
    lazy var childCoordinator:[TabCoordinator] = {
        
        let searchCoordinator = SearchCoordinator(pressenter: UINavigationController())
        searchCoordinator.reload = reload
        let albumCoordinator = AlbumCoordinator(pressenter: UINavigationController())
        albumCoordinator.reload = reload
        let photosCoordinator = PhotosCoordinator(pressenter: UINavigationController())
        photosCoordinator.reload = reload

        return  [photosCoordinator,albumCoordinator,searchCoordinator]
    }()
    
    init(pressenter:UINavigationController) {
        self.pressenter = pressenter
    }
    
    func start() {
        
        let tc = UITabBarController()
        tc.tabBar.setClear()
        pressenter.pushViewController(tc, animated: false)
        rootViewController = tc
        
        tc.viewControllers = childCoordinator.map({ (coordinator) in
            coordinator.start()
            coordinator.pressenter.tabBarItem = UITabBarItem(title: coordinator.name, image: coordinator.image, tag: 0)
            return coordinator.pressenter
        })
    }
    
    func reload()
    {
        childCoordinator.forEach { (coordinator) in
            coordinator.update()
        }
    }
}
