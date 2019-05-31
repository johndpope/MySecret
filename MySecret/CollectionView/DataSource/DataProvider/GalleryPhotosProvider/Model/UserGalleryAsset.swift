//
//  PhotoModel.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit
import Photos
import DifferenceKit

class UserGalleryAsset:MSAssetViewableProtocol, Saveable, Differentiable
{
    var canDelete: Bool = false
    
    
    /// saveable protocol
    var location: CLLocation?
    var type: MSAssetCollectionType? = nil
    var subType: MSAssetCollectionSubtype? = nil
    
    
    /// MSAssetViewableProtocol Requirment
    let localIdentifier: String
    let asstetType: MSAssetMediaType
    var isFavorite: Bool
    let creationDate: Date
    let asset: PHAsset
    var isNSFW: Bool = false
    var hasFace: Bool = false
    var locationDesc: String = ""
    var duration: Double

    
    var differenceIdentifier: Int {
        return (localIdentifier as NSString).integerValue
    }
    
    func isContentEqual(to source: UserGalleryAsset) -> Bool {
        return localIdentifier == source.localIdentifier
    }
    
    
    /// local var
    var requestNum:Int32?
    var shouldCancel:Bool = false

    init(assetID:String, asset: PHAsset, asstetType: MSAssetMediaType) {
        self.asset = asset
        self.localIdentifier = assetID
        self.isFavorite = asset.isFavorite
        self.creationDate = asset.creationDate ?? Date()
        self.asstetType = MSAssetMediaType(rawValue: asset.mediaType.rawValue) ?? MSAssetMediaType.unkonw
        self.duration = asset.duration
        
    }
        
    func loadImageWithCompletionHandler(targetSize:CellTargetSize, imageQuality:ImageQuality ,completion: @escaping (UIImage?, Error?) -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat

        requestNum = PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize.rawValue, contentMode: .aspectFill ,options: options) { image, _ in
            guard let image = image else { return }
            
                completion(image,nil)
            
        }
    }
    
    func canacelLoading()
    {
        
        shouldCancel = true
        if let requestId = requestNum {
            PHImageManager.default().cancelImageRequest(requestId)
        }
    }
    
}
