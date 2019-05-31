//
//  Coordinator Protocol.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

// coordinator protocl. every flow start with coordinator
protocol Coordinator {
    
    var name:String { get }
    var image:UIImage? { get }
    var pressenter:UINavigationController { get }
    func start()
    
}

extension Coordinator {
    var name:String { return "" }
}

protocol TabCoordinator:Coordinator {
    var reload: ()->() { get set}
    func update()
}
