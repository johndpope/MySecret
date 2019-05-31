//
//  GalleryPhotosProvider.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos


class GalleryPhotosProvider:NSObject, DataProviderProtocol
{
    
    let imageCacher = PHCachingImageManager()
    
    var numberOfSections: Int {
        return 1
    }
    
    
    // number of items load from user gallery
    // used by collection view
    func numberOfItemsIn(section: Int) -> Int {
        return allPhotos?.count ?? 0
    }
    
    override init() {
        super.init()
        fetchPhotos { (succ) in
            
        }
    }
    
    /// get cell configurater
    /// hold cell type and data type for presnting
    func getCellConfiguratorItem(at indexPath: IndexPath) -> CellConfigurator? {
        guard let asset = allPhotos?.object(at: indexPath.row),
              let assetMediaType = MSAssetMediaType(rawValue: asset.mediaType.rawValue)
        else { return nil }
        let photoModel = UserGalleryAsset(assetID: asset.localIdentifier, asset: asset, asstetType: assetMediaType)
        return PhotoCellConfig(item: photoModel)
    }
    
    
    // MARK: - var
    fileprivate var allPhotos : PHFetchResult<PHAsset>? = nil
    fileprivate var fetchOptions: PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        return fetchOptions
    }
    
    // fetch images from phone gallery
    func fetchPhotos(complition:(Bool)->())
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        
        var assets:[PHAsset] = []
        self.allPhotos!.enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        
        imageCacher.startCachingImages(for: assets, targetSize: CellTargetSize.thumbnail.rawValue, contentMode: .aspectFill, options: options)
        
        complition(true)
    }
    
    func dataObjects(at indices: [IndexPath]) -> [MSAssetViewableProtocol] {
        return indices.compactMap {
            
            guard let asset = allPhotos?.object(at: $0.row),
                  let assetMediaType = MSAssetMediaType(rawValue: asset.mediaType.rawValue) else {
                      return nil
            }
            
            return UserGalleryAsset(assetID: asset.localIdentifier, asset: asset, asstetType:assetMediaType)
            
        }
    }
    
}
