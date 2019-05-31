//
//  ImageQuality.swift
//  MySecret
//
//  Created by Amir lahav on 23/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

/// scale the photo dowmsampler
enum ImageQuality:CGFloat
{
    // multiple by 2
    case highQuality = 4.0
    
    // device scale
    case fastDeliver = 1.0
}
