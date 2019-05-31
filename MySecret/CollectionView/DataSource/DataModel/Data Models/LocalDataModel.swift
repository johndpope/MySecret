//
//  RealmLocalDataModel.swift
//  MySecret
//
//  Created by Amir lahav on 27/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import DifferenceKit
import RealmSwift


class LocalDataModel<U:MSAssetViewableProtocol & Differentiable & Object>: DataModelProtocol {
    
    typealias Model = U
    
    var realm:Realm {
        return try! Realm()
    }
    
    func fetchData(completion: (Result<[U]>) -> ()) {
        
        let fetchAssets = Array(realm.objects(U.self).sorted(byKeyPath:"creationDate"))
        completion(Result.success(fetchAssets))
    }
}



class DataModel<Z:MSAssetViewableProtocol & Differentiable & Object>
{
    
    var realm:Realm {
        return try! Realm()
    }
    
    func fetchData(with type:MSAssetCollectionType, subtype:MSAssetCollectionSubtype ,completion: (Result<[ArraySection<CollectionViewSection,Z>]>) -> ()) {
        
        var sections:[ArraySection<CollectionViewSection,Z>] = []
        let fetchAssets = MSLocalAssetCollection.fetchAssetCollection(with: type, subtype: subtype, realm: realm)
        
        for (index,collection) in fetchAssets.enumerated() {
            guard let assets = MSLocalAsset.fetchAssets(in: collection) as? Results<Z> else {
                continue
            }
            guard let asset = assets.first else { continue }
            var title = ""
            switch collection.assetCollectionType{
            case .album:
                title = collection.title ?? ""
            case  .moment:
                title = asset.creationDate.toString(dateType: collection.assetCollectionSubtype)
            case .smartAlbum:
                title = collection.assetCollectionSubtype.description ?? "Photos"
            }
            let section = ArraySection(model: CollectionViewSection(id: index, title: title), elements: assets)
                sections.append(section)
        }
        completion(Result.success(sections))
    }
    
    
    func fetchData(with localIdentifier:String ,completion: (Result<[ArraySection<CollectionViewSection,Z>]>) -> ()) {
        
        var sections:[ArraySection<CollectionViewSection,Z>] = []
        let fetchAssets = MSLocalAssetCollection.fetchAssetCollection(with: localIdentifier, realm: realm)
        
        for (index,collection) in fetchAssets.enumerated() {
            guard let assets = MSLocalAsset.fetchAssets(in: collection) as? Results<Z> else {
                continue
            }
            guard let asset = assets.first else { continue }
            var title = ""
            switch collection.assetCollectionType{
            case .album:
                title = collection.title ?? ""
            case  .moment:
                title = asset.creationDate.toString(dateType: collection.assetCollectionSubtype)
            case .smartAlbum:
                title = collection.assetCollectionSubtype.description ?? "Photos"
            }
            
            let section = ArraySection(model: CollectionViewSection(id: index, title: title), elements: assets)
            sections.append(section)
        }
        completion(Result.success(sections))
    }
    
    
    
    
 
}
