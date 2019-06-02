//
//  AlbumFlowLayout.swift
//  MySecret
//
//  Created by Amir lahav on 05/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit


class AlbumFlowLayout: UICollectionViewFlowLayout {

    
    var albumSize:CGFloat = ((min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)) - (4 * 10)-1)/2
    var oneGapUnit:CGFloat = 0
    let labelSize:CGFloat = 50.0

    override init() {
        super.init()
        initiate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initiate()
    }
    
    override var itemSize: CGSize {
        set{}
        get{
            

        
            let width = albumSize
            
            return CGSize(width: width, height: width + labelSize)
        }
    
        
    }
    
    
    
    func initiate()
    {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0.0
        headerReferenceSize =  CGSize(width: UIScreen.main.bounds.width, height: 44)
        
    }

    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func updateInset()
    {
        var totalAlbumWidth:CGFloat = 0
        if UIDevice.current.orientation.isLandscape {
            
            let width:CGFloat = UIScreen.main.bounds.width
            totalAlbumWidth = 3 * albumSize
            oneGapUnit = (width - totalAlbumWidth + 30) / 4
        }else{
            
            let width:CGFloat = UIScreen.main.bounds.width
            totalAlbumWidth = 2 * albumSize
            oneGapUnit = (width - totalAlbumWidth + 20) / 3
        }

        sectionInset = UIEdgeInsets(top: -5, left: oneGapUnit - 10, bottom: 10, right: oneGapUnit)
        let width:CGFloat = UIScreen.main.bounds.width
        print("width intiated \(width)")

    }
    

}
