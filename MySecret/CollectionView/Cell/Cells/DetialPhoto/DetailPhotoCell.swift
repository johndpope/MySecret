//
//  DetailPhotoCell.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class DetailPhotoCell: UICollectionViewCell,ConfigurableCell, Parallexable {

    
    
    @IBOutlet weak var parallexView: UIView?{
        didSet{
        }
    }
    
    func load() {
        print("should load detail cell")
        if let image = image {
            self.load(image: image)
        }
    }
    
    var image:UIImage? = nil
    
    @IBOutlet weak var scrollView: ImageScrollView?
    {
        didSet{
            guard let scrollView = scrollView else { return }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    
    func bind(data photo: MSAssetViewableProtocol, completion:@escaping (Bool)->())
    {
        let targetSize:CellTargetSize = .detail
        let key = String(photo.localIdentifier)
        photo.loadImageWithCompletionHandler(targetSize: targetSize, imageQuality: .highQuality) {[weak self] (image, _) in
            guard let image = image else { return }
            print(key + targetSize.description)
            AssetCache.shared().addImage(key: key + targetSize.description, image: image  )
            
            DispatchQueue.main.async {
                self?.load(image: image)
                completion(true)
            }
        }
    }
    
    func load(image:UIImage?)
    {
        scrollView?.alpha = 0.6
        scrollView?.display(image: image!)

        UIView.animate(withDuration: 0.2) {
            self.scrollView?.alpha = 1.0
        }
    }
    
    override func prepareForReuse() {
        scrollView?.zoomView?.image = nil

    }

}
