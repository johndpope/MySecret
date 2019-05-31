//
//  SelectableAssetPhotoGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 08/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit


class SelectablePhotoGridVC: SectionedPhotoGridVC, GridSectionHeaderViewProtocol {

    var isSelectMode:Bool = false 

    var didPickAsset:(_ at:[MSLocalAsset],_ albumName:String)->() = {(_,_) in  }
    
    var selectedIndexPath: IndexPath!

    var navigationBarHeight:CGFloat = 0 {
        didSet{
        }
    }
    
    var navigationBarHeightBeforeTransition:CGFloat = 0 {
        didSet{
        }
    }
    var deviceOrientationBeforeTransition:UIDeviceOrientation = UIScreen.main.deviceOrientation
    
    var leftInset:CGFloat = 0
    var leftInsetBeforeTrnasition:CGFloat = 0
    
    
    var dataProviderAPI:DataProviderMultiSectionSelectableProtocol? {
        guard let dataProvider = dataSourceAPI?.dataProvider as? DataProviderMultiSectionSelectableProtocol else {
            return nil
        }
        return dataProvider
    }
    
    
    /// collection view data source, special for collection view with selectable headers.
    var dataSourceAPI:CollectionViewHeaderAndCellDataSource?{
        guard let dataSource = dataSource as? CollectionViewHeaderAndCellDataSource  else {
            return nil
        }
        return dataSource
    }

    override init(dataSource: CollectionViewHeaderAndCellDataSource,
         collectionViewLayout: CustomImageFlowLayout = CustomImageFlowLayout(withHeader: true),
         configurator:GridConfigurator = GridConfigurator())
    {
        super.init(dataSource: dataSource, collectionViewLayout: collectionViewLayout, configurator:configurator)
        dataSourceAPI?.uiViewController = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataProviderAPI?.update(selectMode: true)
        configureNavigationButton()
        navigationBarHeight = self.view.safeAreaInsets.top
        rotated()
    }
    
    func configureNavigationButton()
    {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didFinishSelectingPhotos))
    }
    
    @objc func didFinishSelectingPhotos()
    {
        guard let indexPaths = photoGrid?.indexPathsForSelectedItems, let assets = dataSource.dataProvider.dataObjects(at: indexPaths) as? [MSLocalAsset] else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        didPickAsset(assets, albumName)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
    }
    

    
    @objc override func rotated(){

        print("rotate photoVC")
        if let bBar = functionToolBar { bBar.invalidateIntrinsicContentSize() }
        let backgroundHeight:CGFloat = isSelectMode ? 44 : 49
        let landscapeheight:CGFloat = safeAreaInsetsBottom == 0 ? 32 : 49
        toolBackgroundHeightConstrain?.constant = view.frame.width > view.frame.height ? safeAreaInsetsBottom + landscapeheight : safeAreaInsetsBottom + backgroundHeight
    }
    
    
    @objc func selectDidPrsss()
    {
        isSelectMode = !isSelectMode
        
        toolBackgroundHeightConstrain?.constant = getConstaintHeight(selectMode: isSelectMode)
        

        
        if isSelectMode {

            UIView.animate(withDuration: 0.15) {
                
                self.functionToolBar?.alpha = 1
                self.tabBarController?.tabBar.alpha = 0
                self.view.layoutIfNeeded()
                
            }
        }else{

            UIView.animate(withDuration: 0.15, animations: {[weak self] in
                self?.functionToolBar?.alpha = 0
                self?.tabBarController?.tabBar.alpha = 1
                self?.view.layoutIfNeeded()
                }, completion:{ (succ) in
                    self.functionToolBar?.disableAll()
                    
                }
            )}
        
    }
    
    
    func didSelectHeader(at indexPath: IndexPath?) {
        
        guard let indexPath =  indexPath, let dataProvider = self.dataSource.dataProvider as?  DataProviderMultiSectionSelectableProtocol else { return }
        
        if !dataProvider.selectedSection.contains(indexPath)
        {
            photoGrid?.selectItems(in: indexPath.section, animated: true)
        }else {
            photoGrid?.deselectItems(in: indexPath.section, animated: true)
            
        }
        (photoGrid?.indexPathsForSelectedItems?.count)! > 0 ? functionToolBar?.enableAll() : functionToolBar?.disableAll()
        
        dataProviderAPI?.selectHeader(indexPath)
    }
    
    
    
    func getConstaintHeight(selectMode:Bool) -> CGFloat {
        let isLandscape = view.frame.width > view.frame.height
        
        let toolbarHeight:CGFloat = safeAreaInsetsBottom == 0 ? 32 : 49
        
        if isLandscape {
            return safeAreaInsetsBottom + toolbarHeight
        }else if selectMode {
            return safeAreaInsetsBottom + 44
        }else{
            return safeAreaInsetsBottom + 49
        }

    }
    
}


extension SelectablePhotoGridVC{
    
    
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        
        
        guard let currentId = currentIdentifier else {
            fatalError("no current id")
        }
        
        guard let indexPath = dataProviderAPI?.indexPath(to: currentId) else {
            fatalError("no index path")
        }
        
        
        

        //Get the array of visible cells in the collectionView
        guard let visibleCells = self.photoGrid?.indexPathsForVisibleItems, let guardedCell = (self.photoGrid?.cellForItem(at: indexPath) as? BasicPhotoCell) else {

            return UIImageView()
            
        }
        
            //If the current indexPath is not visible in the collectionView,
            //scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(indexPath) {
            
                
                //Guard against nil values
                guard let guardedCell = (self.photoGrid?.cellForItem(at: indexPath) as? BasicPhotoCell) else {
                    //Return a default UIImageView
                    return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
                }
                //The PhotoCollectionViewCell was found in the collectionView, return the image
                
                return guardedCell.imageView!
            }
            else {
                
                //Guard against nil return values
                guard let guardedCell = self.photoGrid?.cellForItem(at: indexPath) as? BasicPhotoCell else {
                    //Return a default UIImageView
                    return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
                }
                //The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.imageView!
            }
            
        }

        //This function prevents the collectionView from accessing a deallocated cell. In the
        //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
        func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath, zoomAnimator:ZoomAnimator) -> CGRect {
            
            
            guard let currentId = currentIdentifier else {
                    fatalError("no current id")
            }
            
            guard let indexPath = dataProviderAPI?.indexPath(to: currentId) else {
                fatalError("no index path")
            }
            
            //Get the currently visible cells from the collectionView
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
           if let unconvertedCell = photoGrid?.cellForItem(at: indexPath){
            
            let frame = unconvertedCell.frame
            if !zoomAnimator.isPresenting{
                
                let converted = photoGrid!.convert(frame, to: self.view)

                if converted.maxY > UIScreen.main.bounds.height - toolBackgroundHeightConstrain!.constant{
                    self.photoGrid?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    if let visibleCells = photoGrid?.indexPathsForVisibleItems {
                        self.photoGrid?.reloadItems(at: visibleCells)
                        
                    }
                    if let frame = (photoGrid?.cellForItem(at: indexPath)!.frame) {
                        return frame
                    }
                }
                if converted.minY < navigationBarHeight + 40.0 {
                    self.photoGrid?.scrollToItem(at: indexPath, at: .top, animated: false)
                    let contentOffest = photoGrid?.contentOffset
                    let addjustContentOffest = CGPoint(x: 0, y: contentOffest!.y - 40)
                    photoGrid?.setContentOffset(addjustContentOffest, animated: false)
                    if let visibleCells = photoGrid?.indexPathsForVisibleItems {
                        self.photoGrid?.reloadItems(at: visibleCells)
                        
                    }
                    if let frame = (photoGrid?.cellForItem(at: indexPath)!.frame) {
                        return frame
                    }
                    
                }
            }

                return frame
            
           }else{
            
                print("didnt find cell")

                self.photoGrid?.scrollToItem(at: indexPath, at: .top, animated: false)
                    if let visibleCells = photoGrid?.indexPathsForVisibleItems {
                        self.photoGrid?.reloadItems(at: visibleCells)

                    }
                let newUnconvertedFrame = photoGrid?.cellForItem(at: indexPath)?.frame
                return newUnconvertedFrame!
            }

        }


}
extension SelectablePhotoGridVC: ZoomAnimatorDelegate {
    
    func referenceImage(for zoomAnimator: ZoomAnimator) -> UIImage? {
        let obj = dataProviderAPI?.dataObjects(at: [self.selectedIndexPath]).first
        
       return DiskManager.getImage(imageName: obj!.localIdentifier + "_detail", targetSize: .detail, imageQuality: .highQuality)
    }
    
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {

        
        if deviceOrientationBeforeTransition == currentDeviceOrientation {
            navigationBarHeight = view.safeAreaInsets.top
        }else{
            navigationBarHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.windows[0].safeAreaInsets.top
        }

        
        leftInset = UIApplication.shared.windows[0].safeAreaInsets.left
        
        if !zoomAnimator.isPresenting {
            
            photoGrid?.collectionViewLayout.invalidateLayout()
            self.view.layoutIfNeeded()
//            self.tabBarController?.tabBar.alpha = 1
//            self.backGroundToolBar?.alpha = 1

//
//
//            print("transition: nphoto grid = \(self.photoGrid?.frame) \nscreen size = \(  UIScreen.main.bounds) \ntop inset \(UIApplication.shared.windows[0].safeAreaInsets.top) \nleft inset \( UIApplication.shared.windows[0].safeAreaInsets.left) \nnav bar hight \(self.navigationController?.navigationBar.frame.height) ")
//
//            print("nav bar before trasition == \(navigationBarHeightBeforeTransition)")
//            print("nav bar after trasition == \(navigationBarHeight)")
//
//            print("left inset before trasition == \(leftInsetBeforeTrnasition)")
//            print("left inset after trasition == \(leftInset)")

        }else{
            deviceOrientationBeforeTransition = currentDeviceOrientation
            navigationBarHeightBeforeTransition = view.safeAreaInsets.top
            leftInsetBeforeTrnasition = view.safeAreaInsets.left

            print("nav bar before trasition == \(navigationBarHeightBeforeTransition) \nleft inset before transiton == \(leftInsetBeforeTrnasition)")
            

        }

        print("is presentig: \(zoomAnimator.isPresenting)")
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        
        guard let currentId = currentIdentifier, let indexPath = dataProviderAPI?.indexPath(to: currentId) else {
            return nil
        }
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: indexPath)

        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        

        guard let currentId = currentIdentifier, let indexPath = dataProviderAPI?.indexPath(to: currentId) else {
            return nil
        }
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: indexPath, zoomAnimator:zoomAnimator)
        
        
        guard let cellFrame = self.photoGrid?.convert(unconvertedFrame, to: self.view) else {
            return nil
        }
        
        
        let finalY = cellFrame.origin.y - (navigationBarHeightBeforeTransition-navigationBarHeight)
        let finalX = cellFrame.origin.x - (leftInsetBeforeTrnasition-leftInset)
        print("leftInsetBeforeTrnasition = \(leftInsetBeforeTrnasition) left inset \(leftInset) ")
        
        print("navigationBarHeightBeforeTransition = \(navigationBarHeightBeforeTransition) navigationBarHeight \(navigationBarHeight) ")

        let finalFrame = CGRect(x: finalX, y: finalY, width: cellFrame.width, height: cellFrame.height)
        print("return converted frame = \(cellFrame), finalFrame: \(finalFrame)")
        return finalFrame
    }
    
}

