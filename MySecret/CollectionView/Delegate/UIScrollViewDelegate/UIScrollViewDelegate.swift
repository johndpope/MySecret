//
//  UIScrollViewDelegate.swift
//  MySecret
//
//  Created by Amir lahav on 23/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit


protocol MSCollectionViewDelegateProtocol:class {
    func scrollViewDidEndDecelerating(at indexPath:IndexPath)
    
}



class UIScrollViewDelegateObject: NSObject,  UIScrollViewDelegate, UICollectionViewDelegate{
    
    let OffsetSpeed: CGFloat             = 35
    weak var collectionView:UICollectionView? = nil
    weak var delegate:MSCollectionViewDelegateProtocol?
    
    private(set) var currentIndexPath:IndexPath{
        didSet{
            print(currentIndexPath)
        }
    }
    
    func set(currentIndexPath:IndexPath)
    {
        self.currentIndexPath = currentIndexPath
    }
    
    init(currentIndexPath:IndexPath) {
        self.currentIndexPath = currentIndexPath
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    
    
    func updateCurrentIndex()
    {
        let visibleCellsIndexPath = collectionView?.indexPathsForVisibleItems
        visibleCellsIndexPath?.forEach({ (indexPath) in
            if let cell = collectionView?.cellForItem(at: indexPath){
                if cell.frame == collectionView?.bounds{
                    currentIndexPath = indexPath
                    delegate?.scrollViewDidEndDecelerating(at: indexPath)
                }
            }
        })
    }
}


enum UserScrollDirection{
    case unknown
    case right
    case left
}
