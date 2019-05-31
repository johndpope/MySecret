//
//  ImageSaveHelper.swift
//  PhotoViewer
//
//  Created by amir lahav on 14.2.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation
import UIKit

struct LoadImageHelper
{
    
    func getImageData(assetId:String) -> Data?
    {
        guard  let document = getDocumentsDirectory() else {
            print("couldnt get document ")
            return nil
        }
        let path = assetId
        let filePath = document.appendingPathComponent("\(path)").path
        let fileURL = document.appendingPathComponent("\(path)")
        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                
                print("try")
                let photoData = try Data(contentsOf: fileURL)
                return photoData
            } catch let error as NSError {
                print("cant load image from device")
                print(error.localizedDescription)
            }
        }else{
            print("file not exist")
        }
        return nil
    }
    
    func deleteImageFromDevice(ID:String, size:ImageSizeExtention )
    {
        guard  let document = getDocumentsDirectory() else {
            return
        }
        let extention:String = size.rawValue
        let path = ID + extention
        let filename = document.appendingPathComponent("\(path)")
        
        do{
            try FileManager.default.removeItem(at: filename)

        }catch let error as NSError {
            print(error.localizedDescription)
            print("cant delete photo")
        }
    }

    func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

}


extension LoadImageHelper{
    

    

    
}

enum FileExension:String {
    case JPG = ".jpg"
    case PNG = ".png"
    case MOV = "_video.MOV"
}

enum ImageSizeExtention: String {
    case thumbnail = "_thumbnail.png"
    case animationTransition = "_animation.png"
    case fullSize = "_main.png"
}
