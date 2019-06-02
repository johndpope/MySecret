//
//  PhotoHeaderModel.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation

class PhotoHeaderModel: MSHeaderViewableProtocol {
    
    var selectButtonIsHidden: Bool = true
    var title: String
    var currentIndexPath: IndexPath?
    var isSelected: Bool = false

    init(title:String) {
        self.title = title
    }
}

struct AlbumHeaderModel: MSHeaderViewableAlbumProtocol {
    
    let title: String
}
