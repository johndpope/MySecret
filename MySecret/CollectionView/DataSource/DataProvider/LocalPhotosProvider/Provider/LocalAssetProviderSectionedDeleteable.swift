//
//  LocalAssetProvider.swift
//  MySecret
//
//  Created by Amir lahav on 20/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import DifferenceKit


class LocalAssetProviderSectionedDeleteable<Z:Differentiable & MSAssetViewableProtocol & Object, F:ConfigurableCell & UICollectionViewCell, S:CollectionCellConfigurator<F,MSAssetViewableProtocol>>:LocalAssetProviderSectioned<Z,F,S>, DataProviderMultiSectionSelectableProtocol
{
    
    var collectionLocalIdentifier:String? = nil
    var selectMode: Bool = false
    var selectedSection = Set<IndexPath>()
//    let dataModel = LocalDataModel<Z>()
    
    var realm:Realm {
        return try! Realm()
    }
    

    convenience init(localIdentifier:String?) {
        self.init(type: .smartAlbum, subtype: .any)
        self.collectionLocalIdentifier = localIdentifier
    }
        
    override func fetchPhotos(complition: (Bool) -> ()) {
        
        
        if let id = collectionLocalIdentifier {
            dataModel.fetchData(with: id) {(result) in
                switch result{
                    
                case .success(let presentableData):
                    presentabelData = presentableData
                    selectedSection.removeAll()
                    
                    complition(true)
                    
                case .error(_):
                    print("error")
                }
            }
        }else{
            dataModel.fetchData(with: colletionType, subtype: collectionSubtype) { (result) in
                switch result{
                    
                case .success(let presentableData):
                    presentabelData = presentableData
                    selectedSection.removeAll()
                    
                    complition(true)
                    
                case .error(_):
                    print("error")
                }
            }
        }
    }
    
//    func cachePhotos(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
//            self.presentabelData.forEach({ (t) in
//                t.elements.forEach({ (t) in
//                    AssetCache.shared().cache(item: t, targetSize: .thumbnail)
//                })
//            })
//        }
//
//    }
    
    
    func removeAssets(fromAlbum:Bool, with indexPaths:[IndexPath],collectionView:UICollectionView?, animation animatoin:Bool, complition:(Bool)->())
    {
        var target = presentabelData.map({$0})
        var assetsToDelete:[MSAssetViewableProtocol] = []
        for indexPath in indexPaths {
            
                let asset = presentabelData[indexPath.section].elements[indexPath.item]
                assetsToDelete.append(asset)
                target[indexPath.section].elements.remove(at: indexPath.item)
                
                if target[indexPath.section].elements.count == 0 {
                    target.remove(at: indexPath.section)
                }
        }

        let changeset = StagedChangeset(source: presentabelData, target: target)
        if animatoin {
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
        
        /// remove assets from specific album by album id
        if fromAlbum {
            guard let realm = try? Realm(),
                let collectionLocalIdentifier = collectionLocalIdentifier,
                let collection = MSLocalAssetCollection.fetchAssetCollection(with: collectionLocalIdentifier, realm: realm).first else {
                    return
            }
                assets.forEach { (asset) in
                    AssetSaver.shared().removeAsset(asset: asset as! MSLocalAsset, collection: collection) { (result) in
                        
                    }
                }
            
        /// remove assets from database

        }else{
            assets.forEach { (asset) in
                if let asset = asset as? MSLocalAsset{
                    AssetSaver.shared().removeAsset(asset: asset, completion: nil)
                }
            }
        }        
    }
    
    
    //// for  vertical gallery scroll
    func numberOfItems(to indexPath:IndexPath)-> Int
    {
        var items = 0
        if indexPath.section == 0 {
            return indexPath.row
        }else{
            for i in 0...(indexPath.section) - 1{
                if i < presentabelData.count {
                    items += presentabelData[i].elements.count
                }
            }
            return items + indexPath.row
        }
    }
    
    //MARK: - CollectionView Header
    
    
    func emptySelection() {
        selectedSection.removeAll()
    }
    
    func selectHeader(_ indexPath:IndexPath)
    {
        if !selectedSection.contains(indexPath){
            selectedSection.insert(indexPath)
        }else{
            selectedSection.remove(indexPath)
        }
    }
    
    func update(selectMode: Bool) {
        self.selectMode = selectMode
    }
    
    override func getHeaderConfiguratorItem(at indexPath: IndexPath) -> HeaderConfigurator? {
        
        if indexPath.section > presentabelData.count - 1 { return nil }
        if indexPath.row > presentabelData[indexPath.section].elements.count - 1 { return nil }
        let header:PhotoHeaderModel = PhotoHeaderModel(title:presentabelData[indexPath.section].model.title ?? "")
        header.selectButtonIsHidden = !selectMode
        header.isSelected = selectedSection.contains(indexPath)
        header.currentIndexPath = indexPath
        return PhotoHeaderConfig(item: header)
    }

    
}


struct CollectionViewSection: Differentiable {
    
    typealias DifferenceIdentifier = Int

    var differenceIdentifier: Int
    {
        return id
    }
    let id:Int
    let title:String?
    func isContentEqual(to source: CollectionViewSection) -> Bool {
        return source.id == id
    }    
}
