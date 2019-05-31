//
//  MSSelectableCreateableAlbumGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 08/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
class MSSelectableCreateableEditableAlbumGridVC:MSAlbumCreateableGridVC, AlbumCollectionViewCellProtocol, AlbumTrashAlertControllerDelegate
{
    var indexPathDeleteAlbum:IndexPath? = nil
    
    func removeAlbum() {
        deleteAlbum()
    }
    
    func deleteBtnDidPress(cell: AlbumCollectionViewCell) {
        
        indexPathDeleteAlbum = albumCollectionView?.indexPath(for: cell)
        
        guard let album =  dataProviderAPI?.dataObjects(at: [indexPathDeleteAlbum!]).first as? MSLocalAssetCollection else { return }
        let alert = TrashAlertController(albumName: "\(album.ablbumName ?? "")")
        alert.albumDelegate = self
        self.present(alert, animated: true, completion: nil)
        
    }
    
    init(dataSource: CollectionViewSectionedDataSource) {
        super.init(dataSource: dataSource)
        albumCollectionView?.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func deleteAlbum()
    {
        guard let indexPath = indexPathDeleteAlbum else { return }
        dataProviderAPI?.removeAssets(fromAlbum: true,
                                      with: [indexPath],
                                      collectionView: albumCollectionView,
                                      animation: true,
                                      complition: { (success) in
                                        print("finish remove album")
        })
        
        
        updateDeleteMode()

    }
    
    
    
    var deleteMode:Bool = false {
        didSet{
            print("deleteMode = \(deleteMode)")
            switch deleteMode {
            case true:
                let done =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.updateDeleteMode))
                self.navigationItem.rightBarButtonItem = done
                albumCollectionView?.allowsSelection = false
            default:
                let edit =  UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.updateDeleteMode))
                self.navigationItem.rightBarButtonItem = edit
                albumCollectionView?.allowsSelection = true
            }
            
        }
        
        
    }
    
    var dataProviderAPI:DataProviderMultiSectionSelectableProtocol? {
        guard let dataProvider = dataSource.dataProvider as? DataProviderMultiSectionSelectableProtocol else {
            return nil
        }
        return dataProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        dataSource.albumCollectionViewController = self
    }
    
    func configureView()
    {
        let add =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.createNewAlbum))
        self.navigationItem.leftBarButtonItem = add
        
        let edit =  UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.updateDeleteMode))
        self.navigationItem.rightBarButtonItem = edit
        
    }
    
    @objc func updateDeleteMode()
    {
        deleteMode = !deleteMode
        dataProviderAPI?.update(selectMode: deleteMode)
        updateVisibleCell()
    }
    
    func updateVisibleCell()
    {
        ///// get index paths for visible items
        let indexs = albumCollectionView?.indexPathsForVisibleItems
        
        /// loop through
        indexs?.forEach({ (indexPath) in
            
            /// get collection data from data provider at index path
            guard let cellData = dataProviderAPI?.dataObjects(at: [indexPath]).first as? MSLocalAssetCollection else { return }
            /// cast cell to AlbumCollectionViewCell
                guard let cell = albumCollectionView?.cellForItem(at: indexPath) as? AlbumCollectionViewCell else { return }
            /// check if cell is user album
            if cellData.assetCollectionType == .album {
                /// update visible cell to current delete mode
                cell.deleteMode(deleteMode)
            }
            
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let album = dataSource.dataProvider.dataObjects(at: [indexPath]).first{
            didSelectAlbum(album.localIdentifier)
            print(album.localIdentifier)
        }else {
            print("didnt find object")
        }
    }
}


