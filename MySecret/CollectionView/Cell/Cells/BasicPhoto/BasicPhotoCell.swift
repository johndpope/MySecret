//
//  PhotoCollectionViewCell.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class BasicPhotoCell: UICollectionViewCell, ConfigurableCell, LoadableCell {
    
    func load() {
        imageView?.image = assetImage
        self.imageView?.alpha = 1.6
        
        UIView.animate(withDuration: 0.2) {
            self.imageView?.alpha = 1.0
        }
    }
    
    var assetImage:UIImage? = nil
    
    
    
    var shouldCancelLoadIamge:Bool = false
    
    @IBOutlet weak var isSelectedIcon: UIImageView?
    {
        didSet{
            guard let isSelectedIcon = isSelectedIcon  else {
                return
            }
            isSelectedIcon.layer.cornerRadius = 12
            isSelectedIcon.layer.borderColor = UIColor.white.cgColor
            isSelectedIcon.layer.borderWidth = 1.0
            isSelectedIcon.isHidden = true
        }
    }
    @IBOutlet weak var isFavorite: UIImageView?{
        didSet{
            guard let isFavorite = isFavorite else { return }
            isFavorite.isHidden = true
        }
    }
    @IBOutlet weak var blurView: UIView?{
        didSet{
            guard let blurView = blurView else {
                return
            }
            blurView.isHidden = true
            blurView.alpha = 0.35
            
        }
    }
    
    override var isSelected: Bool {
        didSet{
            blurView?.isHidden = !isSelected
            isSelectedIcon?.isHidden = !isSelected
        }
    }
    
    @IBOutlet weak var imageView: UIImageView?
    {
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
    
    var photo:MSAssetViewableProtocol?
    
    func bind(data photo: MSAssetViewableProtocol, completion:@escaping (Bool)->())
    {
        isFavorite?.isHidden = !photo.isFavorite
        self.photo = photo
        self.imageView?.image = nil
        let key = String(photo.localIdentifier)
        let targetSize = CellTargetSize.thumbnail
        photo.loadImageWithCompletionHandler(targetSize: targetSize, imageQuality: .highQuality) {[weak self] (image, _) in
            guard let strongSelf = self else { return }
            guard let image = image else {
                        completion(false)
                        return
            }
            AssetCache.shared().addImage(key: key + targetSize.description, image: image)
                    DispatchQueue.main.async {
                        strongSelf.assetImage = image
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
        self.isSelected = false
//        self.photo?.canacelLoading()
//        imageView?.image = nil
    }
}






