//
//  MSPhotoLibrary.swift
//  MySecret
//
//  Created by Amir lahav on 14/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RealmSwift

class MSPhotoLibrary: NSObject {
    
    private static var sharedPhotoLibrary: MSPhotoLibrary = {
        let sharedPhotoLibrary = MSPhotoLibrary()
        
        // Configuration
        // ...
        
        return sharedPhotoLibrary
    }()
    
    class func shared() -> MSPhotoLibrary {
        return sharedPhotoLibrary
    }

    private override init() {
        super.init()
    }
    
    
    func performChanges(_ changeBlock: ((Realm) -> Void)? , completionHandler: ((Bool) -> Void)?)
    {
        let serial = DispatchQueue(label: "joe")
        serial.async {
            guard let realm = try? Realm() else {
                completionHandler?(false)
                return
            }
            changeBlock?(realm)
        }
        completionHandler?(true)
    }
    
    func checkPhotoLibraryPermission(completion:@escaping (Result<Bool>)->()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: completion(Result.success(true))
        //handle authorized status
        case .denied, .restricted : completion(Result.error(authorizationError.denied))
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized: completion(Result.success(true))
                // as above
                case .denied, .restricted: completion(Result.error(authorizationError.denied))
                // as above
                case .notDetermined: completion(Result.error(authorizationError.notDetermined))
                    // won't happen but still
                }
            }
        }
    }
    
    
}

enum authorizationError:Error
{
    case denied
    case notDetermined
}



