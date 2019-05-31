//
//  MSAssetCollectionSubtype.swift
//  MySecret
//
//  Created by Amir lahav on 02/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

@objc enum MSAssetCollectionSubtype:Int {
    
    // user album
    case albumRegular

    // smart albums
    case smartAlbumPanoramas
    case smartAlbumVideos
    case smartAlbumFavorites
    case smartAlbumTimeLapses
    case smartAlbumBursts
    case smartAlbumSlowMoVideos
    case smasrAlbumSelfPortraits
    case smartAlbumScreenShots
    case smartAlbumDepthEffect
    case smartAlbumLivePhotos
    case smartAlbumAnimated
    case smartAlbumLongExposures
    case albumSyncedFaces
    case albumCameraRoll
    case smartAlbumNSFW
    case smartAlbumCars
    case smartAlbumPets

    // moment
    case monthMoment
    case dayMoment
    
    
    
    case any
}


extension MSAssetCollectionSubtype {
    
    static func convert(photoType:PHAssetMediaSubtype) -> MSAssetCollectionSubtype?
    {
        switch photoType {
        case PHAssetMediaSubtype.photoPanorama:         return MSAssetCollectionSubtype.smartAlbumPanoramas
        case PHAssetMediaSubtype.videoHighFrameRate:    return MSAssetCollectionSubtype.smartAlbumSlowMoVideos
        case PHAssetMediaSubtype.videoTimelapse:        return MSAssetCollectionSubtype.smartAlbumTimeLapses
        case PHAssetMediaSubtype.photoScreenshot:       return MSAssetCollectionSubtype.smartAlbumScreenShots
        case PHAssetMediaSubtype.photoDepthEffect:      return MSAssetCollectionSubtype.smartAlbumDepthEffect
        case PHAssetMediaSubtype.photoLive:             return MSAssetCollectionSubtype.smartAlbumLivePhotos
        default: return nil
        }
    }
    
    var description:String?{
        switch self {
        
        case .albumRegular:
            return nil
        
        case .smartAlbumPanoramas:
            return "Panoramas"
        
        case .smartAlbumVideos:
            return "Videos"

        case .smartAlbumFavorites:
            return "Favorite"

        case .smartAlbumTimeLapses:
            return "Time Lapse"

        case .smartAlbumBursts:
            return "Bursts"

        case .smartAlbumSlowMoVideos:
            return "SlowMo"

        case .smasrAlbumSelfPortraits:
            return "Portraits"

        case .smartAlbumScreenShots:
            return "ScreenShots"

        case .smartAlbumDepthEffect:
            return nil

        case .smartAlbumLivePhotos:
            return "Live Photos"

        case .smartAlbumAnimated:
            return "Animated"

        case .smartAlbumLongExposures:
            return nil

        case .albumSyncedFaces:
            return "Faces"

        case .monthMoment:
            return nil

        case .dayMoment:
            return nil

        case .any:
            return nil

        case .albumCameraRoll:
            return "Camera Roll"
        case .smartAlbumNSFW:
            return "NSFW"
            
        case .smartAlbumCars:
            return "Cars"

        case .smartAlbumPets:
            return "Pets"
        }
    }
    
}
