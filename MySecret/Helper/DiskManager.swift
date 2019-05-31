//
//  DocumetnDataBase.swift
//  MySecret
//
//  Created by Amir lahav on 24/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RNCryptor

class DiskManager {
    
   static func saveToDisk(image:UIImage, fileName:String, completion:(Result<String>)->())
    {
        guard  let document = getDocumentsDirectory(), let data = image.pngData() else {
            
            let error = NSError(domain: "cant get dociment folder", code: -781, userInfo: nil)
            completion(Result.error(error))
            return
        }
        
        let password = "password"
        
        let ciphertext = RNCryptor.encrypt(data: data, withPassword: password)
        
        let path = document.appendingPathComponent("\(fileName).png")
        do{
            try ciphertext.write(to: path)
            completion(Result.success(path.absoluteString))
            
        }catch let err{
            
            completion(Result.success(err.localizedDescription))
        }
    }
    
    static func getImage(imageName:String, targetSize:CellTargetSize, imageQuality:ImageQuality) -> UIImage?
    {
        guard  let document = getDocumentsDirectory() else {
            print("couldnt get document ")
            return nil
        }
        let path = imageName + ".png"
        let filePath = document.appendingPathComponent("\(path)").path
        let fileURL = document.appendingPathComponent("\(path)")
        let password = "password"

        if FileManager.default.fileExists(atPath: filePath) {
            
            do {
                let data = try Data(contentsOf: fileURL)
                let originalData = try RNCryptor.decrypt(data: data, withPassword: password)
                return originalData.downSmaple(to: targetSize.rawValue)
                // ...
            } catch {
                print(error)
            }
//            let downSampleImage = Data.downsample(imageAt: fileURL, to: targetSize.rawValue, imageQuality: imageQuality)
//            return downSampleImage
        }else {
            //            print("file not exist")
        }
        return nil
    }
    
    
    private static func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
