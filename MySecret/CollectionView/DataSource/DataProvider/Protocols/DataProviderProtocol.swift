//
//  PhotoViewModel.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

protocol DataProviderProtocol {
    
    
    // collection view
    var numberOfSections:Int { get }
    func numberOfItemsIn(section:Int) -> Int
    
    // fetch images from phone gallery
    func fetchPhotos(complition:(Bool)->())
    
    // cell
    func getCellConfiguratorItem(at indexPath: IndexPath) -> CellConfigurator?

    // data objects
    func dataObjects(at indices:[IndexPath]) -> [MSAssetViewableProtocol]
    
    func getIndexOf(localIdentifier id:String) -> IndexPath?

    
}

extension DataProviderProtocol {
    
    func removeAssets(at indexPaths:[IndexPath],collectionView:UICollectionView?, complition:(Bool)->()) { }
    
    func getIndexOf(localIdentifier id:String) -> IndexPath? {return nil }

    
    
}


protocol DataProviderMultiSectionProtocol:DataProviderProtocol {
    
    init(type: MSAssetCollectionType, subtype:MSAssetCollectionSubtype)
    
    func getHeaderConfiguratorItem(at indexPath: IndexPath) -> HeaderConfigurator?
    
    func indexPath(to id:String) -> IndexPath?
}

protocol DataProviderMultiSectionSelectableProtocol:DataProviderMultiSectionProtocol {
    
    
    var collectionLocalIdentifier:String? { get }

    // header
    var  selectedSection:Set<IndexPath> { get }
    func emptySelection()
    var  selectMode:Bool { get }
    func update(selectMode:Bool)
    func selectHeader(_ indexPath:IndexPath)
    func numberOfItems(to: IndexPath) -> Int
    
    // remove data from album or from DB
    func removeAssets(fromAlbum:Bool, with indexPaths:[IndexPath],  collectionView:UICollectionView?, animation:Bool, complition:(Bool)->())
}





