//
//  PhotoGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class PhotoGridVC: UIViewController, UICollectionViewDelegate {
    
    
    
    var collectionTitle:String = ""
    var safeAreaInsetsBottom: CGFloat {
        let bottom:CGFloat  =  UIApplication.shared.windows[0].safeAreaInsets.bottom
        return bottom
    }
    
    
    
    var currentDeviceOrientation:UIDeviceOrientation {
        return UIScreen.main.deviceOrientation
    }
    
    private(set) var albumName:String = ""

    
    /////// bottom tool bar
    
    @IBOutlet weak var functionToolBar: UIToolbar? {
        didSet{
            guard let toolBar = functionToolBar else { return }
            toolBar.setClear()
            toolBar.alpha = 0.0
            toolBar.disableAll()
        }
    }
    
    ///// tool bar items
    @IBOutlet weak var leftBtn: UIBarButtonItem!
    @IBOutlet weak var rightBtn: UIBarButtonItem!
    @IBOutlet weak var centerBtn: UIBarButtonItem!
    
    @IBOutlet weak var functionBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBackgroundHeightConstrain: NSLayoutConstraint?{
        didSet{
            
        }
    }
    
    ///// tool bar actions can be overide
    @IBAction func leftBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func centerBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func rightBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBOutlet weak var backGroundToolBar: UIToolbar?{
        didSet{
            
        }
    }
   
    /// control the background height
    @IBOutlet weak var tabBarBackgroundBottoConstraint: NSLayoutConstraint!
    
    

    var didSelect:(_ localIdentifier:String) -> Void = { (_) in }
    
    var deleteItem:()->() = { }
    let layout:UICollectionViewLayout
    let dataSource:CollectionViewDataSource
    let configurator:GridConfigurator
    var currentIdentifier:String? = nil {
        didSet{
            print(currentIdentifier)
        }
    }
    
    fileprivate var currentIndexPath: IndexPath? {
        let center = view.convert(photoGrid!.center, to: photoGrid)
        return photoGrid!.indexPathForItem(at: center)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        if let indexAtCenter = currentIndexPath,let layout = photoGrid?.collectionViewLayout as? CustomImageFlowLayout {
            layout.focusedIndexPath = indexAtCenter
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("grid vc view did load")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.reload)
            , name: NSNotification.Name.MSAssetsDidChanges, object: nil)
        
        self.backGroundToolBar?.isHidden = configurator.hideToolbarBackground

        // Do any additional setup after loading the view.
    }
    
    
    @objc func reload()
    {
        print("reload PhotoGridVC")
        dataSource.dataProvider.fetchPhotos(complition: {[weak self] (succ) in
            self?.photoGrid?.reloadData()
        })
    }

    
    init(dataSource:CollectionViewDataSource,collectionViewLayout:UICollectionViewFlowLayout = AssetGridCollectionViewLayout(), configurator:GridConfigurator = GridConfigurator()) {
        self.dataSource = dataSource
        self.layout = collectionViewLayout
        self.configurator = configurator
        super.init(nibName: "PhotoGridVC", bundle: nil)
        self.navigationItem.largeTitleDisplayMode = configurator.displayMode

    }
    
    
    func fetchAndScroll(to localIdentifier:String)
    {
        dataSource.dataProvider.fetchPhotos { (succ) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {[weak self] in
                if let indexPath = self?.dataSource.dataProvider.getIndexOf(localIdentifier: localIdentifier){
                    self?.photoGrid?.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                }
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = collectionTitle
        photoGrid?.contentInsetAdjustmentBehavior = .always
        toolBackgroundHeightConstrain?.constant = 49 + safeAreaInsetsBottom
        

    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = " "
    }
    

    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit photo VC")
    }
    
    
    func setAlbum(name:String)
    {
        self.albumName = name
    }

    @IBOutlet weak var photoGrid: UICollectionView? {
        didSet{
            guard let photoGrid = photoGrid else { return }
            
            photoGrid.registerNib(BasicPhotoCell.self)
            photoGrid.registerNib(TinyCell.self)

            photoGrid.registerHeaderNib(GridSectionHeaderView.self)
            photoGrid.delegate = self
            photoGrid.dataSource = self.dataSource
            photoGrid.isPrefetchingEnabled = false
//            photoGrid.prefetchDataSource = self.dataSource
            photoGrid.allowsMultipleSelection = true
            photoGrid.collectionViewLayout = layout
            dataSource.collectionView = photoGrid

        }
    }
    
    @IBOutlet weak var testcv: UICollectionView?{
        didSet{
            
        }
    }
    
    
    @objc func rotated(){
        
        print("this is not overide")
        if let bBar = functionToolBar { bBar.invalidateIntrinsicContentSize() }

        toolBackgroundHeightConstrain?.constant = view.frame.width > view.frame.height ? safeAreaInsetsBottom + 32 : safeAreaInsetsBottom + 49
    }
    
    
}
