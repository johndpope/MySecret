//
//  Data Extention.swift
//  MySecret
//
//  Created by Amir lahav on 20/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

extension Data
{
    func downSmaple(to pointSize:CGSize, scale:CGFloat = UIScreen.main.scale) -> UIImage?
    {
        
        let imageSourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, imageSourceOptions) else { return nil}
        
        let maxDementionInPixels = Swift.max(pointSize.width ,pointSize.height ) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways:true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform:true,
             kCGImageSourceThumbnailMaxPixelSize:maxDementionInPixels] as CFDictionary
        guard let downsamoledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil
            
        }
        let image = UIImage(cgImage: downsamoledImage)
        return image
    }
    
    static func downsample(imageAt imageURL: URL, to pointSize: CGSize, imageQuality: ImageQuality) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return nil }
        
        let maxDimensionInPixels = Swift.max(pointSize.width, pointSize.height) * UIScreen.main.scale * imageQuality.rawValue
        let downsampleOptions =  [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage =   CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        let image = UIImage(cgImage: downsampledImage)
        return image
        
    }
}
