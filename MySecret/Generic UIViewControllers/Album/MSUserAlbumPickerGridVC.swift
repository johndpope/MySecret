//
//  MSUserAlbumPickerGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 10/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class MSUserAlbumPickerGridVC: MSAlbumCreateableGridVC {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNewAlbumCounter()
        tabBarBackgroundConstraint?.constant = 0
        self.bottomToolbar?.isHidden = true
    }
    
    
    func hideNewAlbumCounter()
    {
        DispatchQueue.main.async {
            [weak self] in
            if let cell = self?.albumCollectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? AlbumCollectionViewCell {
                cell.albumPhotosCount?.isHidden = true
            }
        }
    }

    deinit {
        print("deinit user album picker")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        if indexPath == [0,0] {
            createNewAlbum()
        }else if let album = dataSource.dataProvider.dataObjects(at: [indexPath]).first{
            didSelectAlbum(album.localIdentifier)
            print("i pick this album \(album.localIdentifier)")
        }else{
            print("dident find object")
        }
            

    }
    
    
}
