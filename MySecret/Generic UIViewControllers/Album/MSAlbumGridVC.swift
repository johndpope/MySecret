//
//  MSAlbumVC.swift
//  MySecret
//
//  Created by Amir lahav on 04/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class MSAlbumGridVC: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var bottomToolbar: UIToolbar?{
        didSet{
            
        }
    }
    
    var didSelectAlbum:(String) -> () = {(_) in }
    var safeAreaInsetsBottom:CGFloat {
        return UIApplication.shared.windows[0].safeAreaInsets.bottom
    }
    var collectionViewFlowLayout:AlbumFlowLayout = AlbumFlowLayout()
    
    var currentNumberOfAlbum:Int = 0
    
    @IBOutlet weak var tabBarBackgroundConstraint: NSLayoutConstraint? {
        didSet{
            
        }
    }
    
    @IBOutlet weak var albumCollectionView: UICollectionView? {
        didSet{
            guard let collection = albumCollectionView else { return }
            collection.registerNib(AlbumCollectionViewCell.self)
            collection.registerHeaderNib(AlbumCollectionHeaderView.self)
            collection.allowsMultipleSelection = false
            collection.allowsSelection = true
            collection.delegate = self
            collection.dataSource = dataSource
            collection.collectionViewLayout = collectionViewFlowLayout
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        albumCollectionView?.contentInsetAdjustmentBehavior = .automatic
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func rotated() {
        
        let toolbarHeight:CGFloat = safeAreaInsetsBottom == 0 &&          view.frame.width > view.frame.height ? 32 : 49
        tabBarBackgroundConstraint?.constant =  toolbarHeight + safeAreaInsetsBottom
        collectionViewFlowLayout.updateInset()
        collectionViewFlowLayout.invalidateLayout()
        
    }

    var dataSource:CollectionViewDataSource
    
    init(dataSource:CollectionViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: "MSAlbumGridVC", bundle: nil)
        fetch()
    }
    
    
    @objc func fetch(){
        print("fetch album")
        dataSource.dataProvider.fetchPhotos {[weak self] (succ) in
                self?.albumCollectionView?.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rotated()
        self.tabBarController?.tabBar.alpha = 1.0

    }
}
