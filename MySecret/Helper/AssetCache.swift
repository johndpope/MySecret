//
//  AssetCache.swift
//  MySecret
//
//  Created by Amir lahav on 20/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift






class AssetCache {
    
    
    private static var sharedAssetCache: AssetCache = {
        let sharedAssetCache = AssetCache()
        sharedAssetCache.cache.countLimit = 3000
        // Configuration
        // ...
        
        return sharedAssetCache
    }()

    
    class func shared() -> AssetCache {
        return sharedAssetCache
    }
    
    private init() {}
    
    private let cache: NSCache<NSString,UIImage> = NSCache()
    
    func addImage(key:String, image:UIImage) {
        self.cache.setObject(image, forKey: key as NSString)
    }
    
    private func removeImage(key:String) {
        self.cache.removeObject(forKey: key as NSString)
    }
    
    func getImage(key:String) -> UIImage? {
        return self.cache.object(forKey: key as NSString)
    }
    
    func remove(item:MSAssetViewableProtocol, targetSize:CellTargetSize)
    {
        let key:String = "\(item.localIdentifier)" + targetSize.description

        if self.cache.object(forKey: key as NSString) != nil {
            DispatchQueue.global().async {
                self.removeImage(key: key)
            }
            print("remove image")
            
        }

        
    }
    
    func cache(item:MSAssetViewableProtocol, targetSize:CellTargetSize) {
        
        let key:String = String(item.localIdentifier) + targetSize.description

        
        if self.cache.object(forKey: key as NSString) == nil {

            item.loadImageWithCompletionHandler(targetSize: targetSize, imageQuality: .fastDeliver) { (image, _) in
                guard let image = image else { return }
                DispatchQueue.global().async {
                    self.addImage(key: key, image: image)
                }

                DispatchQueue.main.async {

                }
            }
        }
    
    }
}
