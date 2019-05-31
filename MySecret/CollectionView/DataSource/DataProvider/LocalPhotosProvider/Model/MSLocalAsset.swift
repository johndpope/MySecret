//
//  MSLocalAssetRealm.swift
//  MySecret
//
//  Created by Amir lahav on 20/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import RealmSwift
import DifferenceKit
import Photos


class MSLocalAsset: MSObject, MSAssetViewableProtocol {
    
    var canDelete: Bool = false
    
 
   @objc private(set) dynamic var mediaType:Int = 0
   @objc private(set) dynamic var isFavorite:Bool = false
   @objc private(set) dynamic var duration:Double = 0.0
   @objc private(set) dynamic var phAssetIdentifier:String = ""
    
   var tags = List<String>()

    
   var pixelWidth = RealmOptional<Int>()
   var pixelHeight = RealmOptional<Int>()
    
    
   @objc dynamic var creationDate: Date = Date()
   @objc dynamic var modificationDate: Date?
    
    // need to change to @objc dynamic
    var isNSFW: Bool = false
    var hasFace: Bool = false
    var locationDesc: String = ""
    
    override static func indexedProperties() -> [String]
    {
        return ["creationDate"]
    }
    
    ////// builder
    
    func localIdentifier(_ id:String) -> MSLocalAsset
    {
        self.localIdentifier = id
        return self
    }
    
    func creationDate(_ date:Date) -> MSLocalAsset
    {
        self.creationDate = date
        return self
    }
    
    func mediaType(_ mediaType: Int) -> MSLocalAsset
    {
         self.mediaType = mediaType
         return self
    }
    
    func isFavorite(_ isFavorite:Bool) -> MSLocalAsset
    {
         self.isFavorite = isFavorite
         return self
    }
    
    func duration(_ duration:Double) -> MSLocalAsset
    {
        self.duration = duration
        return self
    }
    
    func asset(_ asset:PHAsset) -> MSLocalAsset
    {
        self.creationDate = asset.creationDate ?? Date()
        self.mediaType = asset.mediaType.rawValue
        self.isFavorite = asset.isFavorite
        self.duration = asset.duration
        self.phAssetIdentifier = asset.localIdentifier
        return self
    }
    
    func nsfw(_ nsfw:Bool) ->MSLocalAsset
    {
        self.isNSFW = nsfw
        return self
    }
    
    func hasFace(_ hasFace:Bool) -> MSLocalAsset{
        self.hasFace = hasFace
        return self
    }
    
    func tags(_ tags:[String]) -> MSLocalAsset{
        self.tags.append(objectsIn: tags)
        return self
    }
    
    
    func build() -> MSLocalAsset{
        let asset = MSLocalAsset()
        asset.localIdentifier = localIdentifier
        asset.creationDate = creationDate
        asset.mediaType = mediaType
        asset.isFavorite = isFavorite
        asset.duration = duration
        return asset
    }
    
    
    
    
    
    
    
   var shouldCancelLoading:Bool = false
    
   var asstetType: MSAssetMediaType
   {
        guard let mediaType = MSAssetMediaType(rawValue: mediaType) else {
                return MSAssetMediaType.unkonw
            }
                return mediaType
    }
    
    func loadImageWithCompletionHandler(targetSize: CellTargetSize,imageQuality:ImageQuality, completion: @escaping (UIImage?, Error?) -> ()) {
    
    shouldCancelLoading = false
    
    let photoRef = ThreadSafeReference(to: self)
    
        DispatchQueue.global().async {
            
            do{
                let realm = try Realm()
                guard let photo = realm.resolve(photoRef) else {

                    // photo was deleted
                    completion(nil, NSError(domain: "photo was deleted", code: -777, userInfo: nil))
                    
                    return
                }
                let imageName:String = photo.localIdentifier + targetSize.description
                
                // load from cache
                if let image = AssetCache.shared().getImage(key: imageName){
//                    print("load from cache")
                    completion(image,nil)
                }else{
//                    print("load from disk")

//                    if !self.shouldCancelLoading {
                        // load from disk
                        
                        let image = DiskManager.getImage(imageName: imageName, targetSize: targetSize, imageQuality: imageQuality)

                        completion(image,nil)
//                    }else{
//                        print("cancel loading")
//                    }

                }
            }catch let err{
                completion(nil, err as Error)
            }
    }
   }
    
    class func fetchAssets(in collection: MSLocalAssetCollection) -> Results<MSLocalAsset>?
    {
        guard let realm = try? Realm() else {print("cant get realm") ; return nil }
        return realm.objects(MSLocalAssetCollection.self).filter({$0.localIdentifier == collection.localIdentifier}).first?.assets.sorted(byKeyPath: "creationDate")
    }
    
    class func fetchAssets() -> Results<MSLocalAsset>?
    {
        guard let realm = try? Realm() else {print("cant get realm") ; return nil }
        return realm.objects(MSLocalAsset.self)
    }
    
    class func fetchAssets(_ localIdentifer:[String], realm:Realm) -> [MSLocalAsset]
    {

        let assets:[MSLocalAsset] = localIdentifer.compactMap { (identifier)  in
            let predicate = NSPredicate(format: "localIdentifier = %@", identifier)
            return realm.objects(MSLocalAsset.self).filter(predicate).first
        }
        return assets

    }
    
   func canacelLoading() {
        shouldCancelLoading = true
   }

}
