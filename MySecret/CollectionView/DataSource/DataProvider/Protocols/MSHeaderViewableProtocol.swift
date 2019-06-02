//
//  MSHeaderViewableProtocol.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

protocol MSHeaderViewableProtocol {
    var selectButtonIsHidden:Bool { get }
    var title:String { get }
    var isSelected:Bool { get }
    var currentIndexPath:IndexPath? { get }
}

protocol MSHeaderViewableAlbumProtocol
{
    var title:String { get }
}
