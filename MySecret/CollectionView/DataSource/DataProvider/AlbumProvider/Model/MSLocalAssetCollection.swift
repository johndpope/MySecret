//
//  MSAssetCollection.swift
//  MySecret
//
//  Created by Amir lahav on 02/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import DifferenceKit

class MSLocalAssetCollection: MSLocalCollection, MSAssetViewableProtocol{
    
    
    
    /// MSAssetViewableProtocol
    var asstetType: MSAssetMediaType = .unkonw
    var isFavorite: Bool = false
    var creationDate: Date {
        return startDate
    }
    var canDelete: Bool = false

    var duration: Double = 0.0
    var isNSFW: Bool = false
    var hasFace: Bool = false
    var locationDesc: String {
        return localizedLocationNams.first ?? ""
    }
    
    var canManualAppendAssets:Bool {
        return assetCollectionType == .album
    }
    
    func canacelLoading() { }
    
    
    @objc dynamic var assetCollectionType:MSAssetCollectionType = .album
    @objc dynamic var assetCollectionSubtype:MSAssetCollectionSubtype = .albumRegular
    @objc dynamic var startDate:Date = Date()
    
    convenience init(with Type:MSAssetCollectionType, subtype:MSAssetCollectionSubtype, title:String? = nil) {
        self.init()
        self.localIdentifier = String.random()
        self.assetCollectionType = Type
        self.assetCollectionSubtype = subtype
        self.title = title
    }
    
    override static func indexedProperties() -> [String]
    {
        return ["representDade"]
    }
    
    var localizedLocationNams = List<String>()
    
    var assets = List<MSLocalAsset>()
    
    var count:Int {
        return assets.count
    }
    
    var year:String? {
        return assets.sorted(byKeyPath: "creationDate", ascending: true).first?.creationDate.year
    }
    
    var month:String? {
        return assets.sorted(byKeyPath: "creationDate", ascending: true).first?.creationDate.month
    }

    var endDate:Date? {
        return assets.sorted(byKeyPath: "creationDate", ascending: false).first?.creationDate
    }
    
    var ablbumName:String? {
        if assetCollectionType != .album {
            return assetCollectionSubtype.description
        }else{
            return title
        }
    }
    
    func loadImageWithCompletionHandler(targetSize:CellTargetSize, imageQuality:ImageQuality ,completion: @escaping (UIImage?, Error?) -> ()){

        guard let asset = MSLocalAsset.fetchAssets(in: self)?.last else {
            let error = NSError(domain: "cant get any photo in collection ", code: -230, userInfo: nil)
            completion(nil, error)
            return }
        
        let photoRef = ThreadSafeReference(to: asset)

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

                    completion(image,nil)
                }else{
                    let image = DiskManager.getImage(imageName: imageName, targetSize: targetSize, imageQuality: imageQuality)
                    
                    completion(image,nil)
                }
            }catch let err{
                completion(nil, err as Error)
            }
        }
        
        
        
        
    }
    
    
    /// fetch collection by local idnetifier
    class func fetchAssetCollection(title:String, realm:Realm ,canBeEmpty:Bool = true) -> Results<MSLocalAssetCollection> {
        
        var predicate = NSPredicate()
        
        if canBeEmpty {
            /// fetch precice album by subtype
            predicate = NSPredicate(format: "title = %@ ", title)
        }else {
            /// fetch precice album by subtype
            predicate = NSPredicate(format: "title = %@ AND assets.@count > 0", title)
        }
        
        
        return realm.objects(MSLocalAssetCollection.self).filter(predicate).sorted(byKeyPath: "startDate")
        
    }
    
    
    
    
    
    
    
    ///
    /// fetch collection by type and subtype
    class func fetchAssetCollection(with type: MSAssetCollectionType, subtype:MSAssetCollectionSubtype, realm:Realm, ascending:Bool = true) -> Results<MSLocalAssetCollection> {
        
        var predicate = NSPredicate()
        
        /// fetch any subtype album
        if subtype == .any {
            print("any")
           predicate = NSPredicate(format: "assetCollectionType = %d AND assets.@count > 0", type.rawValue)
        }else if type ==  .album{
           
            /// fetch precice album by subtype
           predicate = NSPredicate(format: "assetCollectionType = %d", type.rawValue, subtype.rawValue)
        }else{
            /// fetch precice album by subtype
            predicate = NSPredicate(format: "assetCollectionType = %d AND assetCollectionSubtype = %d AND assets.@count > 0", type.rawValue, subtype.rawValue)
        }


        return realm.objects(MSLocalAssetCollection.self).filter(predicate).sorted(byKeyPath: "startDate", ascending: ascending)

    }
    
    
    ///
    /// fetch collection by local idnetifier
    class func fetchAssetCollection(with localIdentifier:String, realm:Realm ,canBeEmpty:Bool = true) -> Results<MSLocalAssetCollection> {
        
        var predicate = NSPredicate()
        
        if canBeEmpty {
            /// fetch precice album by subtype
            predicate = NSPredicate(format: "localIdentifier = %@ ", localIdentifier)
        }else {
            /// fetch precice album by subtype
            predicate = NSPredicate(format: "localIdentifier = %@ AND assets.@count > 0", localIdentifier)
        }

        
        return realm.objects(MSLocalAssetCollection.self).filter(predicate).sorted(byKeyPath: "startDate")
        
    }
    
    
    class func fetchSmartAlbumCollection(subtype:MSAssetCollectionSubtype, realm:Realm) -> MSLocalAssetCollection
    {
        if let collection = realm.objects(MSLocalAssetCollection.self).filter({$0.assetCollectionSubtype == subtype}).first{
            return collection
        }else{
            
            let collection = MSLocalAssetCollection(with: .smartAlbum, subtype: subtype)
            collection.startDate = Date()
            collection.localIdentifier = String.random()
            
            do{
                try realm.write {
                    realm.add(collection)
                }
            }catch let err{
                print(err)
            }
            
            return collection
        }
    }
    
    
    
    
    /// create temp collection for search or user selection
    class func transientAssetCollection(with assets:[MSLocalAsset], title:String?) -> MSLocalAssetCollection
    {
        let assetCollection = MSLocalAssetCollection()
        assetCollection.assets.insert(contentsOf: assets, at: 0)
        if let title = title {
            assetCollection.title = title
        }
        return assetCollection
    }
    
    
    
    
    
    // class function return collection of type yearMoment
    // every moment contain all asset in certain year
    class func fetchMonthAssetCollection(by date:Date ,realm:Realm) -> MSLocalAssetCollection
    {
        if let collection = realm.objects(MSLocalAssetCollection.self).filter({$0.month == date.month && $0.assetCollectionSubtype == MSAssetCollectionSubtype.monthMoment }).first{
            print("found year collection")
            return collection
        }else{
            
            let collection = MSLocalAssetCollection(with: .moment, subtype: .monthMoment)
            collection.localIdentifier = String.random()
            collection.startDate = date

            do{
                try realm.write {
                    realm.add(collection)
                }
            }catch let err{
                print(err)
            }
            
            return collection
        }
    }
    
    
    
    // class function return collection of type dayMoment
    // every moment contain all asset in certain day
    class func fetchMomentAssetCollection(by date:Date ,realm:Realm) -> MSLocalAssetCollection?
    {
        let collection = realm.objects(MSLocalAssetCollection.self).filter({$0.startDate.yearMonthDay == date.yearMonthDay && $0.assetCollectionSubtype == .dayMoment}).first
            print("founc day moment \(date.yearMonthDay)")
        
        return collection
    }
    
    
    
    class func requsrCreateMomentAssetCollection(by date:Date ,realm:Realm, completion:(MSLocalAssetCollection?)->())
    {
        let collection = realm.objects(MSLocalAssetCollection.self).filter({$0.startDate.yearMonthDay == date.yearMonthDay && $0.assetCollectionSubtype == .dayMoment})
        if collection.count == 0 {
            let collection = MSLocalAssetCollection(with: .moment, subtype: .dayMoment)
            collection.startDate = date
            collection.localIdentifier = String.random()
            
            do{
                try realm.write {
                    realm.add(collection)
                    completion(collection)
                }
            }catch let err{
                completion(nil)
                print(err)
            }
        }

    }
    
    class func requestDeleteCollection(localIdentifier:String, completion:(Bool)->()) {
        
        guard let realm = try? Realm(), let collection = fetchAssetCollection(with: localIdentifier, realm: realm).first else {
            completion(false)
            return
        }
        
        do{
            try realm.write {
                realm.delete(collection)
            }
            completion(true)
        }catch let err{
            completion(false)
        }        
    }
    
    
    class func requsrCreateSmartAssetCollection(subtype:MSAssetCollectionSubtype ,realm:Realm, completion:(Bool)->())
    {
        let collectionCount = MSLocalAssetCollection.fetchAssetCollection(with: .smartAlbum, subtype: subtype, realm: realm).count
        if collectionCount == 0 {
            
            let collection = MSLocalAssetCollection(with: .smartAlbum, subtype: subtype)
            do{
                try realm.write {
                realm.add(collection)
                    completion(true)
                }
            }catch let err{
                completion(false)
                print(err)
            }            
        }
    }
    
    
    
    static func isAddable(localIdentifier:String) -> Bool {
        guard  let realm = try? Realm(), let collection = MSLocalAssetCollection.fetchAssetCollection(with: localIdentifier, realm: realm).first else{
            return false
        }
        return collection.canManualAppendAssets
    }
    
    static func albumName(localIdentifier:String) -> String?
    {
        guard  let realm = try? Realm(), let collection = MSLocalAssetCollection.fetchAssetCollection(with: localIdentifier, realm: realm).first else{
            return nil
        }
        return collection.ablbumName
    }
    
}
