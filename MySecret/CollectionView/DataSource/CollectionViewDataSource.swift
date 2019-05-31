//
//  CollectionView DataSource.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit


class CollectionViewDataSource:NSObject, UICollectionViewDataSource
{
    weak var collectionView:UICollectionView? = nil{
        didSet{

        }
    }
    weak var albumCollectionViewController:MSSelectableCreateableEditableAlbumGridVC?
    
    /// model protocol for data source requirments
    /// any class model need to conform this protocol
    var dataProvider:DataProviderProtocol
    let preferedCellSize:CellTargetSize
    
    init(dataProvider:DataProviderProtocol, preferedCellSize:CellTargetSize = .thumbnail) {
        self.dataProvider = dataProvider
        self.preferedCellSize = preferedCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsIn(section:section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = dataProvider.getCellConfiguratorItem(at: indexPath) else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: item).reuseId, for: indexPath)
        item.configure(cell: cell, completion:{(success) in
            
            DispatchQueue.main.async {
                guard let cell = collectionView.cellForItem(at: indexPath) as? LoadableCell else {
                    return
                }
                cell.load()
            }
        })
        if let cell = cell as? AlbumCollectionViewCell{
            cell.delegate = albumCollectionViewController
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider.numberOfSections
    }    
}


class CollectionViewSectionedDataSource:CollectionViewDataSource
{
    weak var uiViewController:SelectableDeletablePhotoGridVC?
    
    init(dataProvider: DataProviderMultiSectionProtocol) {
        super.init(dataProvider: dataProvider)
        print("init CollectionViewSectionedDataSource")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("call me")

        guard let dataProvider = dataProvider as?  DataProviderMultiSectionProtocol else { return UICollectionReusableView()}
        
        guard let item = dataProvider.getHeaderConfiguratorItem(at: indexPath) else { return UICollectionReusableView()}
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: type(of: item).reuseId, for: indexPath)
        
        if let headerView = headerView as? CollectionViewHeader {
            headerView.delegate = uiViewController
        }
        item.configure(header: headerView, completion: {(success) in
            print(headerView)
        })
        return headerView
    }
}


class CollectionViewHeaderAndCellDataSource:CollectionViewDataSource
{
    

    
    weak var uiViewController:SelectablePhotoGridVC?

    // todo
    init(dataProvider: DataProviderMultiSectionProtocol) {
        super.init(dataProvider: dataProvider)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let dataProvider = dataProvider as?  DataProviderMultiSectionProtocol else { return UICollectionReusableView()}
        
        guard let item = dataProvider.getHeaderConfiguratorItem(at: indexPath) else { return UICollectionReusableView()}
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: type(of: item).reuseId, for: indexPath)
        
        if let headerView = headerView as? CollectionViewHeader {
            headerView.delegate = uiViewController
        }
        item.configure(header: headerView, completion: {(success) in
            print(headerView)
        })
        
        return headerView
        
    }

}
