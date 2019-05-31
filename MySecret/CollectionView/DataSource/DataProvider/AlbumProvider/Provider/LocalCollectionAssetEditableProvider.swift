//
//  LocalCollectionAssetProvider.swift
//  MySecret
//
//  Created by Amir lahav on 04/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit
import RealmSwift

class LocalCollectionAssetEditableProvider<Z:MSLocalAssetCollection, F:ConfigurableCell & UICollectionViewCell, S:CollectionCellConfigurator<F,MSLocalAssetCollection>>:NSObject , DataProviderMultiSectionSelectableProtocol
{
    var collectionLocalIdentifier: String? = nil

    
    var presentabelData:[ArraySection<CollectionViewSection,Z>] = []

    var selectedSection: Set<IndexPath> = Set<IndexPath>()
    
    func emptySelection() {
        selectedSection.removeAll()
    }
    
    var selectMode: Bool = false
    
    func update(selectMode: Bool) {
        self.selectMode = selectMode
    }
    
    func selectHeader(_ indexPath: IndexPath) {
        
    }
    
    func numberOfItems(to: IndexPath) -> Int {
        return 0
    }
    
    convenience override init() {
        self.init(type: .album, subtype: .any)
    }
    
    required init(type: MSAssetCollectionType, subtype: MSAssetCollectionSubtype) {
        
    }
    
    func getHeaderConfiguratorItem(at indexPath: IndexPath) -> HeaderConfigurator? {
        print("need header")
        let section = presentabelData[indexPath.section].model
        let albumModel = AlbumHeaderModel(title:section.title!)
        
        return AlbumHeaderConfig(item: albumModel)
        // todo
        return nil
    }
    
    var numberOfSections: Int {
        return presentabelData.count
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return presentabelData[section].elements.count
    }
    
    func fetchPhotos(complition: (Bool) -> ()) {
    
        guard let realm = try? Realm() else{ return }
        
        presentabelData.removeAll()

        var userSection = ArraySection(model: CollectionViewSection(id:0, title: "My Albums"), elements: [Z]())
       
        
        if let cameraRoll = MSLocalAssetCollection.fetchAssetCollection(with: .smartAlbum, subtype: .albumCameraRoll, realm: realm).first as? Z {
            userSection.elements.append(cameraRoll)
        }
        
        if let favoriteAlbum = MSLocalAssetCollection.fetchAssetCollection(with: .smartAlbum, subtype: .smartAlbumFavorites, realm: realm).first as? Z {
            userSection.elements.append(favoriteAlbum)
        }
        
        guard  let userAlbum  = MSLocalAssetCollection.fetchAssetCollection(with: .album, subtype: .albumRegular, realm: realm, ascending:false) as? Results<Z> else { return }
        
        userSection.elements.append(contentsOf: userAlbum)

        
        guard let smartAlbums = MSLocalAssetCollection.fetchAssetCollection(with: .smartAlbum, subtype: .any, realm: realm) as? Results<Z> else {
            return
        }
        
        let filterCameraRollAlbums = smartAlbums.filter({
            $0.assetCollectionSubtype != .albumCameraRoll
        })
        
        let filterFavorite = filterCameraRollAlbums.filter({
        $0.assetCollectionSubtype != .smartAlbumFavorites
        })

        
        let smartAlbumSection = ArraySection(model: CollectionViewSection(id:1, title: "Smart Albums"), elements: filterFavorite)

        if !userSection.elements.isEmpty{
            presentabelData.append(userSection)
        }
        if !smartAlbumSection.elements.isEmpty{
            presentabelData.append(smartAlbumSection)
        }
        complition(true)
    }
    
    func getCellConfiguratorItem(at indexPath: IndexPath) -> CellConfigurator? {
        let asset = presentabelData[indexPath.section].elements[indexPath.item]
        if asset.assetCollectionType == .album {
            asset.canDelete = selectMode
        }
        return S(item: asset)
    }
    
    func dataObjects(at indices: [IndexPath]) -> [MSAssetViewableProtocol] {
        
        let objects:[MSAssetViewableProtocol] = indices.map { (indexPath)  in
            return presentabelData[indexPath.section].elements[indexPath.item]
        }
        return objects
    }
    
    
    
    func removeAssets(fromAlbum:Bool, with indexPaths: [IndexPath], collectionView: UICollectionView?, animation: Bool, complition: (Bool) -> ()) {
        
        var target = presentabelData.map({$0})
        var assetsToDelete:[MSAssetViewableProtocol] = []
        for indexPath in indexPaths {
            
            let collection = presentabelData[indexPath.section].elements[indexPath.item]
            assetsToDelete.append(collection)
            target[indexPath.section].elements.remove(at: indexPath.item)
            
            if target[indexPath.section].elements.count == 0 {
                target.remove(at: indexPath.section)
            }
        }
        
        let changeset = StagedChangeset(source: presentabelData, target: target)
        if animation {
            collectionView?.reload(using: changeset, setData: { (data) in
                presentabelData = data
            })
        }else{
            collectionView?.reload(using: changeset, interrupt: { $0.changeCount > 1
            }, setData: { (data) in
                presentabelData = data
            })
        }
        removeDBObjects(fromAlbum: fromAlbum, assets: assetsToDelete)

        complition(true)
  
    }
    
    func removeDBObjects(fromAlbum:Bool, assets:[MSAssetViewableProtocol]){
        assets.forEach { (asset) in
            MSLocalAssetCollection.requestDeleteCollection(localIdentifier: asset.localIdentifier, completion: { (success) in
                print("deleeetteeeeeee album")
            })
        }
    }
    
    func indexPath(to id: String) -> IndexPath? {
        for (sectionIndex, section) in presentabelData.enumerated(){
            for (itemIndex, item) in section.elements.enumerated(){
                if item.localIdentifier == id {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
    

    
}
