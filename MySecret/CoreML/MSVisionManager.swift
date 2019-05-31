//
//  MSVisionManager.swift
//  MySecret
//
//  Created by Amir lahav on 11/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import CoreML
import Vision
import UIKit

class MSVisionManager: NSObject {
    
    private static var sharedVisionManager: MSVisionManager = {
        let sharedAssetSaver = MSVisionManager()
        
        // Configuration
        // ...
        
        return sharedAssetSaver
    }()
    
    class func shared() -> MSVisionManager {
        return sharedVisionManager
    }
    
    func faceRequest() -> VNRequest
    {
        return  VNDetectFaceRectanglesRequest()
    }
    
    func nsfwRequest() -> VNCoreMLRequest?
    {
        guard let model = try? VNCoreMLModel(for: Nudity().model) else {
            return nil
        }
        let request =  VNCoreMLRequest(model:model)
        request.imageCropAndScaleOption = .centerCrop
        return request
        
    }
    
    func objectClassificationRequest() -> VNCoreMLRequest?
    {
        guard let model = try? VNCoreMLModel(for: MobileNetV2_SSDLite().model) else {
            return nil
        }
        let request =  VNCoreMLRequest(model:model)
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
    
    func imageClassificationRequest() -> VNCoreMLRequest?
    {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {

            return nil
        }
        let request =  VNCoreMLRequest(model:model)
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
    
    
    func perform(request:[VNRequest], from image:UIImage, completion:(Bool)->())
    {
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform(request)
            completion(true)
        }catch let err{
            print(err)
            completion(false)
        }
    }
    
    func detect(image:UIImage, completion:@escaping (VisionResult?)->())
    {
        
        var requests:[VNRequest] = []
        let faceRequest =  self.faceRequest()
        requests.append(faceRequest)
        
        
        var imageClassificaitonResult:VNCoreMLRequest?
        if let imageClassificaitonRequest = imageClassificationRequest(){
            imageClassificaitonResult = imageClassificaitonRequest
            requests.append(imageClassificaitonRequest)
        }
        
        var nsfwRequestResult:VNCoreMLRequest?
        if let nsfwRequest = self.nsfwRequest(){
            nsfwRequestResult = nsfwRequest
            requests.append(nsfwRequest)
        }
        var objectClassificationResult:VNCoreMLRequest?
        if let objectClassificationRequest = self.objectClassificationRequest(){
            objectClassificationResult = objectClassificationRequest
            requests.append(objectClassificationRequest)
        }
        guard let cgImage = image.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform(requests)
        }catch let err{
            print(err)
            completion(nil)
        }
        
        var nsfw:Bool = false
        var hasFace = false
        var tags:[String] = []
        if let faceResult =  faceRequest.results as? [VNFaceObservation]
        {
            if let confidance = faceResult.first?.confidence{
                if confidance > 0.7{
                    hasFace = true
                }
            }
        }
        if let ntfsResutl = nsfwRequestResult?.results?.first as? VNClassificationObservation{
            nsfw = ntfsResutl.identifier == "NSFW" && ntfsResutl.confidence > 0.8

        }
        if let tagsResulat = objectClassificationResult?.results as? [VNRecognizedObjectObservation]{
//            tags.append(tagsResulat.identifier)
            tags.append(contentsOf: fetchTags(result: tagsResulat))
            print(tags)
        }
        if let result = imageClassificaitonResult?.results?.first as? VNClassificationObservation {
            print("objcet is: \(result.identifier), confidance: \(result.confidence)")
        }
        
        
        let finalResult = VisionResult(hasFace: hasFace, nsfw: nsfw, tags: tags)
        completion(finalResult)
        
    }
    
    
    
    /// get top 3 tags that have more then 70% confidence
    func fetchTags(result:[VNRecognizedObjectObservation]) -> [String]
    {
        var tags:[String] = []

        if let labels = result.first?.labels {
            for i in 0...3{
                if labels[i].confidence > 0.2 {
                    tags.append(labels[i].identifier)
                }
                
            }
        }
        return tags
    }

}



struct VisionResult {
    let hasFace:Bool
    let nsfw:Bool
    let tags:[String]
}
