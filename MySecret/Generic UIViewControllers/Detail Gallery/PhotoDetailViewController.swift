//
//  PhotoDetailViewController.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, PhotosTrashAlertControllerDelegate {
    
    func removeFromAlbum() {
        removeItems(fromAlbum: true)

    }
    
    func deletePhoto() {
        removeItems(fromAlbum: false)
    }
    
    
    var safeAreaInsetsBottom:CGFloat    {
        return UIApplication.shared.windows[0].safeAreaInsets.bottom
    }

    @IBOutlet weak var dummyImageView: UIImageView?{
        didSet{
            guard let dummy = dummyImageView else {
                return
            }
            dummy.contentMode = .scaleAspectFit
            dummy.isHidden = true
        }
    }
    
    
    @IBOutlet weak var toolbarBackground: UIToolbar?{
        didSet{
        }
    }
    @IBOutlet weak var toolbarBackgroundHeightConstrain: NSLayoutConstraint?
    {
        didSet{
            
        }
    }
    @IBOutlet weak var tabBarBottomConstrain: NSLayoutConstraint?{
        didSet{
            
        }
    }
    @IBOutlet weak var functionToolBar: UIToolbar? {
        didSet{
            guard let toolBar = functionToolBar else {
                return
            }
            toolBar.alpha = 0.0
            toolBar.setClear()
        }
    }
    
    ///// tool bar items
    @IBOutlet weak var leftBtn: UIBarButtonItem!
    @IBOutlet weak var rightBtn: UIBarButtonItem!
    @IBOutlet weak var centerBtn: UIBarButtonItem!
    
    ///// tool bar actions can be overide
    @IBAction func leftBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func centerBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func rightBtn(_ sender: UIBarButtonItem) {
        
        let alert = TrashAlertController(numberOfPhotos: 1, isUserAlbum: configurator.canManualAppendAssets)
        alert.photosDelegate = self
        self.present(alert, animated: true, completion: nil)
    }
    
    
    var dataSource:CollectionViewDataSource? = nil
    var uiScrollViewDelgate:UIScrollViewDelegateObject =  UIScrollViewDelegateObject(currentIndexPath: IndexPath(item: 0, section: 0))
    var dismissAtIndexPath:(String)->() = {_ in }
    var deleteItem:()->() = {}
    var lastDeviceOrientation:UIDeviceOrientation  = UIScreen.main.deviceOrientation
    var transitionController = ZoomTransitionController()
    let configurator:GridConfigurator


    
    /// provide data for this collection view
    /// can be from disk or user photo gallery
    
    private var dataProviderAPI:DataProviderMultiSectionSelectableProtocol? {
        guard let dataProvider = dataSourceAPI?.dataProvider as? DataProviderMultiSectionSelectableProtocol else {
            return nil
        }
        return dataProvider
    }
    
    /// collection view data source, special for collection view with selectable headers.
    private var dataSourceAPI:CollectionViewDataSource?{
        guard let dataSource = dataSource  else {
            return nil
        }
        return dataSource
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        setup()
        navigationItem.largeTitleDisplayMode = .never
        detailPhotoCollection?.contentInsetAdjustmentBehavior = .never
        rotated()


        // Do any additional setup after loading the view.
    }
    
    
    func setup()
    {
        let editBtn =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action:  nil)
        navigationItem.rightBarButtonItems = [editBtn]
    }
    
    @objc func removeItems(fromAlbum:Bool)
    {
        let cell = detailPhotoCollection?.cellForItem(at: uiScrollViewDelgate.currentIndexPath)
        UIView.animate(withDuration: 0.15, animations: {
            cell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            cell?.alpha = 0.0
        }) {[weak self] (succ) in
            guard let strongSelf = self else { return }
            strongSelf.dataProviderAPI?.removeAssets(fromAlbum: fromAlbum, with: [strongSelf.uiScrollViewDelgate.currentIndexPath], collectionView: strongSelf.detailPhotoCollection, animation: false, complition: {[weak self] _ in
                if strongSelf.dataProviderAPI?.numberOfSections == 0 {
                    strongSelf.functionToolBar?.disableAll()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self?.uiScrollViewDelgate.updateCurrentIndex()
                })
                self?.deleteItem()
            })
        }
        }

    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func rotated(){
        

        if let bBar = functionToolBar { bBar.invalidateIntrinsicContentSize() }
        tabBarBottomConstrain?.constant = -safeAreaInsetsBottom
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // show the dummy imageView
        print("viewWillTransitionToSize")
        
        guard let cell = detailPhotoCollection?.cellForItem(at: uiScrollViewDelgate.currentIndexPath) as?  DetailPhotoCell else { return }
        self.dummyImageView?.image = cell.scrollView?.zoomView?.image
        self.dummyImageView?.isHidden = false
        
        let height:CGFloat = size.width > size.height && safeAreaInsetsBottom == 0 ? 32 : 44
        
        
        coordinator.animate(alongsideTransition: { (context) in
            var frame:CGRect = self.dummyImageView?.frame ?? CGRect.zero
            frame.size = size
            self.dummyImageView?.frame = frame

            self.toolbarBackgroundHeightConstrain?.constant = height + self.safeAreaInsetsBottom
            print(self.safeAreaInsetsBottom)
            
        }) { (context) in
            self.dummyImageView?.isHidden = true

        }
    }

    

    init(dataSource:CollectionViewDataSource, scrollTo localIdentifier:String, configurator:GridConfigurator = GridConfigurator()) {
        self.dataSource = dataSource
        self.configurator = configurator
        super.init(nibName: nil, bundle: nil)

        dataSource.dataProvider.fetchPhotos { (succ) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                
                if let indexPath = self.dataSource?.dataProvider.getIndexOf(localIdentifier: localIdentifier){
                    if let asset = dataSource.dataProvider.dataObjects(at: [indexPath]).first{
                        self.title = asset.creationDate.toString(dateType: .dayMoment)
                    }
                    guard let itemsCount = self.dataProviderAPI?.numberOfItems(to:indexPath), let width = self.detailPhotoCollection?.frame.width else { return }
                    let contentOffSet = (width) * CGFloat(itemsCount)
                    
                    self.detailPhotoCollection?.contentOffset = CGPoint(x: contentOffSet, y:0)
                    self.uiScrollViewDelgate.set(currentIndexPath:indexPath)
                }

            }
            
            
            
            
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        print("remove detail vc")
    }
    
    
    @IBOutlet weak var detailPhotoCollection: UICollectionView? {
        didSet{
            
            guard let photoGrid = detailPhotoCollection else { return }
            
            photoGrid.registerNib(DetailPhotoCell.self)
            photoGrid.delegate = uiScrollViewDelgate
            uiScrollViewDelgate.delegate = self
            self.uiScrollViewDelgate.collectionView = detailPhotoCollection
            photoGrid.dataSource = self.dataSource
            photoGrid.isPagingEnabled = true
            photoGrid.alpha = 0
            let layout = AssetDetailCollectionViewLayout()
            photoGrid.collectionViewLayout = layout
            
        }
    }

}


extension PhotoDetailViewController:MSCollectionViewDelegateProtocol{
    
    func scrollViewDidEndDecelerating(at indexPath: IndexPath) {
        if let asset =   dataSource?.dataProvider.dataObjects(at: [indexPath]).first {
            self.title = asset.creationDate.toString(dateType: .dayMoment)
            dismissAtIndexPath(asset.localIdentifier)
        }
    }
    
    
}


extension PhotoDetailViewController: ZoomAnimatorDelegate {
    
    
    func referenceImage(for zoomAnimator: ZoomAnimator) -> UIImage? {
        let cell  = detailPhotoCollection?.cellForItem(at: uiScrollViewDelgate.currentIndexPath) as? DetailPhotoCell
        return cell?.scrollView?.zoomView?.image
    }
    
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        toolbarBackground?.alpha = 1.0
        self.functionToolBar?.alpha = 1.0
    

    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        self.detailPhotoCollection?.alpha = 1.0

    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        let cell  = detailPhotoCollection?.cellForItem(at: uiScrollViewDelgate.currentIndexPath) as? DetailPhotoCell
        return cell?.scrollView?.zoomView ?? UIImageView()
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        guard let cell  = detailPhotoCollection?.cellForItem(at: uiScrollViewDelgate.currentIndexPath) as? DetailPhotoCell ,let imageView = cell.scrollView?.zoomView  else {
            return nil
        }
        
        let frame = self.view.convert(imageView.frame, to: self.view)
        return frame
    }
}
