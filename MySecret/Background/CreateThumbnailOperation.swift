//
//  CreateThumbnailOperation.swift
//  MySecret
//
//  Created by Amir lahav on 11/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

class CreateThumbnailOperation: MSOperation {
 
    private let phAsset:PHAsset
    private let randomId:String
    private let targetSize:CellTargetSize
    private let contentMode: PHImageContentMode
    
    init(phAsset:PHAsset, with randomId:String, targetSize:CellTargetSize,contentMode: PHImageContentMode) {
        self.phAsset = phAsset
        self.randomId = randomId
        self.targetSize = targetSize
        self.contentMode = contentMode
    }
    
    override func main() {
       
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
        /// asset requset options
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.resizeMode = .exact
        
        executing(true)

        /// requst image from photo manager
        PHImageManager.default().requestImage(for: phAsset, targetSize: targetSize.rawValue, contentMode: contentMode, options: options) {[unowned self] (image, _) in
            
            // cant get actual image from PHImageManager
            guard let image = image else {
                let error = NSError(domain: "cant get image from cache manager", code: -779, userInfo: nil)
                self.executing(false)
                self.finish(true)
                return
            }
            
            // save the thumbnail to disk
            DiskManager.saveToDisk(image: image, fileName: self.randomId + self.targetSize.description, completion: { (result) in
                
                switch result {
                case .success(_):
                    self.executing(false)
                    self.finish(true)
                case .error(let err):
                    // cant save photo to disk
                    let error = NSError(domain: "cant save thumbnail with error \(err)", code: -779, userInfo: nil)
                    self.executing(false)
                    self.finish(true)
                }
            })
        }
    }
    
}
