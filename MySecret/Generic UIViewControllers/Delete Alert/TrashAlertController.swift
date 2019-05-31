//
//  TrachAlertController.swift
//  MySecret
//
//  Created by Amir lahav on 11/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

protocol PhotosTrashAlertControllerDelegate:class {
    func removeFromAlbum()
    func deletePhoto()
}

protocol AlbumTrashAlertControllerDelegate:class {
    func removeAlbum()
}

class TrashAlertController: UIAlertController {
    
    weak var albumDelegate:AlbumTrashAlertControllerDelegate?
    
    weak var photosDelegate:PhotosTrashAlertControllerDelegate?
    
    convenience init(albumName:String)
    {
        self.init()
        title = "Delete \"\(albumName)\""
        message = "Are you sure you wnat to delete the album \"\(albumName)\"? \n The photos will not be deleted"
        
        self.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] (alertAction) in
            self?.albumDelegate?.removeAlbum()
            self?.dismiss(animated: true, completion: nil)
            
        }))
        
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }))
        
    }
    

    convenience init(numberOfPhotos:Int, isUserAlbum:Bool){
        self.init()
        
        message = nil
        title = nil
        
        let text = { () -> String in
            if numberOfPhotos == 0 {
                return "Delete Photo"
            }
            return numberOfPhotos == 1 ? "Delete 1 photo" : "Delete \(numberOfPhotos) Photos"
        }
        
        let titleHeader = { () -> String in
            
            return numberOfPhotos == 1 ? "Photo" : "Photos"
            
        }
        
        switch isUserAlbum {
        case true:
            
            self.addAction(UIAlertAction(title: "Remove from album", style: .destructive, handler: {[weak self] (alertAction) in
                self?.photosDelegate?.removeFromAlbum()
                self?.dismiss(animated: true, completion: nil)
            }))
            
            self.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] (alertAction) in
                self?.photosDelegate?.deletePhoto()
                self?.dismiss(animated: true, completion: nil)

            }))
            
        default:
            title = "This \(titleHeader()) will be removed from private albums"
            
            self.addAction(UIAlertAction(title: text(), style: .destructive, handler: {[weak self] (_) in
                self?.photosDelegate?.deletePhoto()
                self?.dismiss(animated: true, completion: nil)

            }))
        }
        
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }))
        
    }
    
    deinit {
        print("remove alert controller")
    }

    
}
