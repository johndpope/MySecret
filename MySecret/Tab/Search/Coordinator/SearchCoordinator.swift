//
//  SearchCoordinator.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit


class SearchCoordinator : TabCoordinator {
    
    func update() {
        /// to do reloading data
    }
    
        
    var reload: () -> () = { }
    var pressenter: UINavigationController
    var searchConroller:SearchViewController?
    var name:String = "Search"
    var image:UIImage? = UIImage(named: "SearchTabIcon")
    
    init(pressenter:UINavigationController) {
        self.pressenter = pressenter
        pressenter.navigationBar.prefersLargeTitles = true
    }
    
    func start() {
        let sc = SearchViewController()
        sc.title = "Search"
        sc.view.backgroundColor = .white
        pressenter.pushViewController(sc, animated: false)
        searchConroller = sc
    }
}
