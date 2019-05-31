//
//  LocalUserCollectionAssetProvider.swift
//  MySecret
//
//  Created by Amir lahav on 10/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit
import RealmSwift

class LocalUserCollectionAssetProvider<Z:MSLocalAssetCollection, F:ConfigurableCell & UICollectionViewCell, S:CollectionCellConfigurator<F,MSLocalAssetCollection>>:NSObject, DataProviderProtocol
{

    var presentabelData:[ArraySection<CollectionViewSection,Z>] = []

    
    var numberOfSections: Int {
        return presentabelData.count
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return presentabelData[section].elements.count
    }
    
    func fetchPhotos(complition: (Bool) -> ()) {
        
        guard let realm = try? Realm() else{ return }
        
        var userSection = ArraySection(model: CollectionViewSection(id:0, title: "My Albums"), elements: [Z]())
        
        guard let emptyAlbum = MSLocalAssetCollection.transientAssetCollection(with: [], title: "New Album...") as? Z else { return }
        
        guard  let userAlbum  = MSLocalAssetCollection.fetchAssetCollection(with: .album, subtype: .albumRegular, realm: realm, ascending:false) as? Results<Z> else { return }
        
        presentabelData.removeAll()
        userSection.elements.append(emptyAlbum)
        userSection.elements.append(contentsOf: userAlbum)
        presentabelData.append(userSection)

        complition(true)

    }
    
    func getCellConfiguratorItem(at indexPath: IndexPath) -> CellConfigurator? {
        let asset = presentabelData[indexPath.section].elements[indexPath.item]
        return S(item: asset)
    }
    
    func dataObjects(at indices: [IndexPath]) -> [MSAssetViewableProtocol] {
        let objects:[MSAssetViewableProtocol] = indices.map { (indexPath)  in
            return presentabelData[indexPath.section].elements[indexPath.item]
        }
        return objects
    }
    
    
}
