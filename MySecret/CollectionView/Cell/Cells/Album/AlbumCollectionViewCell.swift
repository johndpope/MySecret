//
//  AlbumCollectionViewCell.swift
//  MySecret
//
//  Created by Amir lahav on 04/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

protocol AlbumCollectionViewCellProtocol:class {
    func deleteBtnDidPress(cell:AlbumCollectionViewCell)
}


class AlbumCollectionViewCell: UICollectionViewCell, ConfigurableCell {
    
    weak var delegate:AlbumCollectionViewCellProtocol?

    @IBOutlet weak var cancelBtn: UIButton? {
        didSet{
            guard let btn = cancelBtn else {
                return
            }
            btn.layer.cornerRadius = btn.frame.size.width / 2
            btn.alpha = 0
        }
    }
    @IBOutlet weak var albumCover: UIImageView?{
        didSet{
            guard let view = albumCover else {
                return
            }
            view.layer.cornerRadius = 4
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var albumTitle: UILabel?{
        didSet{
            
        }
    }
    @IBOutlet weak var albumPhotosCount: UILabel?{
        didSet{
            
        }
    }
 
    func deleteMode(_ mode:Bool)
    {
        UIView.animate(withDuration: 0.15) {
            self.cancelBtn?.alpha = !mode ? 0.0 : 1.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func cancelDidPress(_ sender: UIButton) {
        delegate?.deleteBtnDidPress(cell: self)
    }
    
    
    
    func bind(data: MSLocalAssetCollection, completion: @escaping (Bool) -> ()) {
        
        switch data.assetCollectionType {
        case .album:
            albumTitle?.text = data.title
        case .smartAlbum:
            albumTitle?.text = data.assetCollectionSubtype.description
        case .moment:
            break
        }
        
        deleteMode(data.canDelete)
        
        albumPhotosCount?.text = "\(data.count)"
        data.loadImageWithCompletionHandler(targetSize: .detail, imageQuality: .highQuality) {[weak self] (image, err) in
            if let image = image {
                DispatchQueue.main.async {
                    self?.albumCover?.image = image
                }
            }else {
                DispatchQueue.main.async {
                    self?.albumCover?.image = UIImage(named: "Album Cover")
                }
            }
        }

    }
    
    override func prepareForReuse() {
        self.albumCover?.image = UIImage(named: "Album Cover")
    }
    
}
