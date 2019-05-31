//
//  AlbumCollectionHeaderView.swift
//  MySecret
//
//  Created by Amir lahav on 17/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class AlbumCollectionHeaderView: UICollectionReusableView, ConfigurableCell, HeaderAlbumReuseableView {
    
    @IBOutlet weak var title: UILabel?{
        didSet{
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(data:MSHeaderViewableAlbumProtocol, completion:(Bool)->())
    {
        print("bind me text: \(data.title)")
        title?.text = data.title
    }
    
}
