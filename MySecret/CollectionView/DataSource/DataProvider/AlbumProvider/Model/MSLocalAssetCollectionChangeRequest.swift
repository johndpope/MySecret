//
//  MSLocalAssetCollectionChangeRequest.swift
//  MySecret
//
//  Created by Amir lahav on 10/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import RealmSwift

final class MSLocalAssetCollectionChangeRequest:NSObject
{
    let collection:MSLocalAssetCollection
    let realm:Realm
    static var placeHolder:MSLocalAssetCollection = MSLocalAssetCollection()
    
    init?(for collection: MSLocalAssetCollection, realm:Realm){
        self.collection = collection
        self.realm = realm
    }
    
    
    class func creationRequestForAssetCollection(withTitle:String, realm:Realm) -> MSLocalAssetCollectionChangeRequest? {
        
        let collection = MSLocalAssetCollection(with: .album, subtype: .albumRegular, title: withTitle)
        do{
            try realm.write {
                realm.add(collection, update: true)
            }
            placeHolder = collection
            
            return MSLocalAssetCollectionChangeRequest(for: collection, realm: realm)

        }catch {
            
            print("error saving new collection to realm")
            return nil
        }
    }
    
    
    
    
    func append(assets:[MSLocalAsset], realm:Realm, completion:(Result<Any>)->())
    {
        
        do{
            try realm.write {
                // can add only assts that are not been added before
                assets.forEach({ (asset) in
                    if !collection.assets.contains(asset) {
                        collection.assets.append(asset)
                    }
                })
                
                
            }
            completion(Result.success(true))
        }catch let err as NSError
        {
            completion(Result.error(err))
        }
    }
}
