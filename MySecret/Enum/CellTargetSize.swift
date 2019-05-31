//
//  CellTargetSize.swift
//  MySecret
//
//  Created by Amir lahav on 23/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
enum CellTargetSize {
    
    // small cell in grid view
    case thumbnail
    
    // large detail cell (video or photo)
    case detail
    
    // extrimly small cells
    case tiny
    
    // for CoreML
    case AI
    
}

extension CellTargetSize:RawRepresentable
{
    typealias RawValue = CGSize

    
    init?(rawValue: CGSize) {
        return nil
    }
    
    var rawValue: CGSize {
        let scale = UIScreen.main.scale 
        switch self {
        case .thumbnail:
            let size = (UIScreen.main.bounds.width / 3) * scale
            return CGSize(width: size, height: size)
        case .detail:
            let width = UIScreen.main.bounds.width * scale
            let height = UIScreen.main.bounds.height * scale

            return CGSize(width: width, height: height)
        case .tiny:
            let size = UIScreen.main.bounds.width / 12 * scale
            return CGSize(width: size, height: size)
        case .AI:
            let size = 224.0
            return CGSize(width: size, height: size)
        }
    }
    
    var description:String {
        switch self {
        case .thumbnail:
            return "_thumbnail"
        case .detail:
            return "_detail"
        case .tiny:
            return "_tiny"
        case .AI:
            return "_coreML"
        }
    }

}
