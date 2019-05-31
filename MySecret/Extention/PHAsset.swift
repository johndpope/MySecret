//
//  PHAsset.swift
//  MySecret
//
//  Created by Amir lahav on 23/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

extension PHAsset
{
    func getAssetThumbnail(size: CGFloat, complition:@escaping ((UIImage?))->())
    {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale,height: size * retinaScale)
        let cropSizeLength = min(pixelWidth, pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(pixelWidth), y: 1.0/CGFloat(pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: self, targetSize: retinaSquare, contentMode: .aspectFill, options: options, resultHandler: {(result, info)->Void in
            guard let image = result else {
                complition(nil)
                return
            }
            complition(image)
        })
    }
}
