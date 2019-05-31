//
//  AssetSaver.swift
//  MySecret
//
//  Created by Amir lahav on 20/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Photos



class AssetSaver
{
    
    private let serialQueue = DispatchQueue(label: "background", qos: .utility)
    private var realm:Realm {
        return try! Realm()
    }
    
    typealias completion = (Result<Any>)->()
    
    private static var sharedAssetSaver: AssetSaver = {
        let sharedAssetSaver = AssetSaver()
        
        // Configuration
        // ...
        
        return sharedAssetSaver
    }()
    
    class func shared() -> AssetSaver {
        return sharedAssetSaver
    }
    
    
    func save(assets:[Saveable], completion:@escaping ()->())
    {
        
        let queue = DispatchQueue(label: "com.gcd.myQueue")
        let assetCount = assets.count - 1
        if assetCount == -1 {
            print("didnt select any assets")
            completion()
        }
        for (index, asset) in assets.enumerated()
            {
                queue.async {

                    if !self.isExist(assetId: asset.asset.localIdentifier){
                    print("index \(index)")

                    autoreleasepool{
                    let randomId = String.random()
                        
                        self.save(asset: asset,randomId:randomId, completion: {[weak self] (result) in
                            
                            guard let strongSelf = self else{
                                
                                if assetCount == index {
                                    DispatchQueue.main.async {
                                        completion()
                                    }
                                }
                                return
                            }
                            
                        switch result {
                        case .success(let str):
                            print(str)
                        case .error(let err):
                            print("couldnt save asset \(err)")
                            strongSelf.removeAsset(randomId: randomId, completion: { (result) in
                                print("remove realm object")
                            })
                        }
                            if assetCount == index {
                                DispatchQueue.main.async {
                                    completion()
                                }
                            }
                    })
                }
                    }else{
                        print("exist")
                        print(assetCount, index)
                        if assetCount == index {
                            DispatchQueue.main.async {
                                completion()
                            }
                        }
                    }
                }

            }
        
        

        

    }
    
    private func save(asset:Saveable, randomId:String, completion:@escaping completion)
    {
        
        
        
//            1. save full image to disk
//            2. save thumbnail to disk
//            3. save tiny to disk
//
//            4. get asset location
//            5. check if asset has face
//            5. check if asset is nsfw
        
        
        var placeHoler = MSLocalAsset()
            .localIdentifier(randomId)
            .asset(asset.asset)
        
        
        
        
        let semaphore = DispatchSemaphore(value: 1)
        
        var coreMLImage224X224:UIImage?
        
        semaphore.wait()
        // create thumbnail from fetch asset
        // leave on success
        // return on error
        saveImage(phAsset: asset.asset, with: randomId, targetSize: .thumbnail, contentMode: .aspectFit, completion: { (result) in
            switch result {
            case .success(_):
                print("leave after create thumbnail")
                //                        group.leave()
                print("compltion got photo back")
                semaphore.signal()
            case .error(let err):
                print(err.localizedDescription)
                completion(Result.error(err))
                return
            }
        })
        
        semaphore.wait()
        // create thumbnail from fetch asset
        // leave on success
        // return on error
        saveImage(phAsset: asset.asset, with: randomId, targetSize: .AI, contentMode: .aspectFill, completion: { (result) in
            switch result {
            case .success(let image):
                print("leave after create thumbnail")
                //                        group.leave()
                print("compltion got photo back")
                coreMLImage224X224 = image
                semaphore.signal()
            case .error(let err):
                print(err.localizedDescription)
                completion(Result.error(err))
                return
            }
        })
        
        semaphore.wait()
        placeHoler = MSLocalAsset()
            .localIdentifier(randomId)
            .asset(asset.asset)
        
        MSVisionManager.shared().detect(image: coreMLImage224X224!) { (result) in
            if let result = result{
                

            placeHoler = placeHoler.nsfw(result.nsfw)
                                   .hasFace(result.hasFace)
                                   .tags(result.tags)
            }
        }
        
        
        semaphore.signal()
        
        semaphore.wait()
        // create thumbnail from fetch asset
        // leave on success
        // return on error
        saveImage(phAsset: asset.asset, with: randomId, targetSize: .detail, contentMode: .aspectFit, completion: { (result) in
            switch result {
            case .success(_):
                print("leave after create detail")
                semaphore.signal()
            case .error(let err):
                print(err.localizedDescription)
                completion(Result.error(err))
                return
            }
        })
        
        
        

                
        semaphore.wait()
                // create thumbnail from fetch asset
                // leave on success
                // return on error
        saveImage(phAsset: asset.asset, with: randomId, targetSize: .tiny, contentMode: .aspectFill, completion: { (result) in
                    switch result {
                    case .success(_):
                        print("leave after create tiny thumbnail")
                        semaphore.signal()
                    case .error(let err):
                        print(err.localizedDescription)
                        completion(Result.error(err))
                        return
                    }
            })
                

        
        
            semaphore.wait()
            // create and save new asset object realm
            // leave on success
            // return on error
        
        
        
                
        saveToRealm(placeHolder: placeHoler, asset: asset, randomId: randomId, completion: { (result) in
                    switch result{
                    case .success(_):
                        print("leave after saveToRealm")
                        
                        semaphore.signal()
                    case .error(let err):
                        print(err.localizedDescription)
                        completion(Result.error(err))
                        return
                        
                    }
                })
        
        
        semaphore.wait()
        
            completion(Result.success("photo \(randomId) has been saved"))
        
        semaphore.signal()

            // if all success get notify on main queue
            // else return before
//            group.notify(queue: .main) {
//            }
        
    }
    


    func removeAsset(randomId:String, completion:completion)
    {
        if let asset = getAsset(randomId: randomId){
            do{
                try realm.write {
                    realm.delete(asset)
                    completion(Result.success("remove succesfully"))
                }
            }catch let err{
                    completion(Result.error(err))
            }
        }
    }
    
    
    
    
    func removeAsset(asset:MSLocalAsset, completion:completion?)
    {
        do{
            try realm.write {
                realm.delete(asset)
                completion?(Result.success("remove succesfully"))
            }
        }catch let err{
            completion?(Result.error(err))
        }
    }
    
    func removeAsset(asset:MSLocalAsset, collection:MSLocalAssetCollection, completion:completion?)
    {
        do{
            try realm.write {
                if let objectIndex = collection.assets.index(of: asset){
                    collection.assets.remove(at: objectIndex)
                    print("assets removed")
                    completion?(Result.success("remove succesfully"))
                }
            }
        }catch let err{
            completion?(Result.error(err))
        }
    }
    
    private func isExist(assetId:String) -> Bool
    {
       return realm.objects(MSLocalAsset.self).filter({$0.phAssetIdentifier == assetId}).count.boolValue
    }
    private func getAsset(randomId:String) -> MSLocalAsset?
    {
        return realm.objects(MSLocalAsset.self).filter({$0.localIdentifier == randomId}).first
    }
    
    
    private func saveImage(phAsset:PHAsset, with randomId:String, targetSize:CellTargetSize,contentMode: PHImageContentMode, completion:@escaping (Result<UIImage>)->())
    {
        
        /// asset requset options
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.resizeMode = .exact
        
        /// requst image from photo manager
        PHImageManager.default().requestImage(for: phAsset, targetSize: targetSize.rawValue, contentMode: contentMode, options: options) { (image, _) in
            
            // cant get actual image from PHImageManager
            guard let image = image else {
                let error = NSError(domain: "cant get image from cache manager", code: -779, userInfo: nil)
                completion(Result.error(error))
                return
            }

            // save image to disk
            DiskManager.saveToDisk(image: image, fileName: randomId + targetSize.description, completion: { (result) in
                
                switch result {
                case .success(_):
                    
                    completion(Result.success(image))
                case .error(let err):
                    
                    // cant save photo to disk
                    let error = NSError(domain: "cant save thumbnail with error \(err)", code: -779, userInfo: nil)
                    completion(Result.error(error as Error))
                }
            })
        }
    }
    
    
    func saveToRealm(placeHolder:MSLocalAsset, asset: Saveable , randomId:String, completion:completion){

        let collections = getCollections(for: asset, placeHolder: placeHolder, realm: realm)
        
        do{
            try realm.write {
                
                collections.forEach({ (collection) in
                    collection.assets.append(placeHolder)
                })
                completion(Result.success("Saved to realm"))
            }
        }catch let err{
            completion(Result.error(err))
        }
        
    }
    
    func getCollections(for asset:Saveable, placeHolder:MSLocalAsset, realm:Realm) -> [MSLocalAssetCollection]
    {
        var collections:[MSLocalAssetCollection] = []
        
        
        if placeHolder.isNSFW {
            let nsfwAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .smartAlbumNSFW, realm: realm)
            collections.append(nsfwAlbum)
            return collections
        }
 
        if let momentCollection = MSLocalAssetCollection.fetchMomentAssetCollection(by: asset.creationDate, realm: realm) {
            collections.append(momentCollection)

        }else{
            MSLocalAssetCollection.requsrCreateMomentAssetCollection(by: asset.creationDate, realm: realm) { (collection) in
                guard let collection = collection else { return }
                collections.append(collection)
            }
        }
        
        let monthCollection = MSLocalAssetCollection.fetchMonthAssetCollection(by: asset.creationDate, realm: realm)
            collections.append(monthCollection)
        
        if let subtype = MSAssetCollectionSubtype.convert(photoType: asset.asset.mediaSubtypes){

            let smartAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: subtype, realm: realm)
            collections.append(smartAlbum)
        }
        
        let cameraRoll = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .albumCameraRoll, realm: realm)
            collections.append(cameraRoll)
        
        
        if asset.asset.isFavorite {
            let favoriteAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .smartAlbumFavorites, realm: realm)
                collections.append(favoriteAlbum)
        }
        
        if asset.asset.mediaType == .video {
            let smartAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .smartAlbumVideos, realm: realm)
            collections.append(smartAlbum)
        }
        
        if placeHolder.hasFace {
            let facesAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .albumSyncedFaces, realm: realm)
            collections.append(facesAlbum)
        }
        
        if placeHolder.tags.contains("car"){
            let carAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .smartAlbumCars, realm: realm)
            collections.append(carAlbum)
        }
        
        if placeHolder.tags.contains("dog") || placeHolder.tags.contains("cat"){
            let petsAlbum = MSLocalAssetCollection.fetchSmartAlbumCollection(subtype: .smartAlbumPets, realm: realm)
            print("found pets")
            collections.append(petsAlbum)
        }
        return collections
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func saveFullImage(from asset:Saveable, randomId:String, completion:@escaping completion){
        
        asset.loadImageWithCompletionHandler(targetSize: .detail, imageQuality: .highQuality) {[weak self] (image, _) in
            
            guard let image = image else {
                
                let error = NSError(domain: "cant get image from disk target size\(CellTargetSize.detail) and photo quality\(ImageQuality.highQuality)", code: -779, userInfo: nil)
                completion(Result.error(error))
                return
                
            }
            DiskManager.saveToDisk(image: image, fileName: randomId, completion: {(result) in
                
                switch result{
                case .success(_):
                    completion(Result.success("We save big photo"))
                    return
                case .error(let err):
                    completion(Result.error(err))
                    return
                }
            })
            
        }
    }
}
