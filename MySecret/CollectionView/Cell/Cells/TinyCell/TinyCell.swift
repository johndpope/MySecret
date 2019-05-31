//
//  TinyCell.swift
//  MySecret
//
//  Created by Amir lahav on 03/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class TinyCell: UICollectionViewCell, ConfigurableCell, LoadableCell {
    
    
    var image:UIImage? = nil
    
    func load() {
        imageView?.image = image
        self.imageView?.alpha = 0.6
        
        UIView.animate(withDuration: 0.2) {
            self.imageView?.alpha = 1.0
        }
    }
    

    @IBOutlet weak var imageView: UIImageView? {
        didSet{
            guard let imageView = imageView else {
            return
            }
            imageView.contentMode = .scaleAspectFill

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func bind(data photo: MSAssetViewableProtocol, completion:@escaping (Bool)->())
    {

        self.imageView?.image = nil
        let key = String(photo.localIdentifier)
        let targetSize = CellTargetSize.tiny
        photo.loadImageWithCompletionHandler(targetSize: targetSize, imageQuality: .highQuality) {[weak self] (image, _) in
            guard let strongSelf = self else { return }
            guard let image = image else {
                completion(false)
                return
            }
            AssetCache.shared().addImage(key: key + targetSize.description, image: image)
            DispatchQueue.main.async {
                strongSelf.image = image
                completion(true)
                //                            strongSelf.load(image: image)
            }
            
        }
    }
    
    func load(image:UIImage?)
    {
        self.imageView?.image = image
        self.imageView?.alpha = 0.6
        
        UIView.animate(withDuration: 0.2) {
            self.imageView?.alpha = 1.0
        }
    }
    
    
    override func prepareForReuse() {
        imageView?.image = nil
        image = nil
    }

}
