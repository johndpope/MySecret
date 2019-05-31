//
//  ImportUserPhotosGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation


import UIKit

class ImportUserPhotosGridVC: PhotoGridVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backGroundToolBar?.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateTitle(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateTitle(collectionView)
        
    }

    
    func updateTitle(_ collectionView: UICollectionView)
    {
        if let numberOfAssetsSelected = collectionView.indexPathsForSelectedItems?.count {
                self.title = numberOfAssetsSelected.toString()
        }
    }
    
}
