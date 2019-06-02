//
//  SelectableDeletablePhotoGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 22/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class SelectableDeletablePhotoGridVC: SelectablePhotoGridVC, PhotosTrashAlertControllerDelegate {
    
    func removeFromAlbum() {
        removeItems(fromAlbum: true)
    }
    
    func deletePhoto() {
        removeItems(fromAlbum: false)
    }
    
    
    var addToDidPress:(_ selectedAsset:[MSAssetViewableProtocol])->() = {_ in }
    var pushAsseterPicker:(String)->() = {_ in }


    @objc func removeItems(fromAlbum:Bool)
    {
        guard let indexPaths = photoGrid?.indexPathsForSelectedItems else {
            print("no itmes found")
            return
        }
        let sortedIndexPath = indexPaths.sorted(by: {$0>$1})
        dataProviderAPI?.removeAssets(fromAlbum: fromAlbum, with: sortedIndexPath, collectionView: photoGrid, animation: true, complition: {[weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.photoGrid?.reloadItems(at: (self?.photoGrid?.indexPathsForVisibleItems)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self?.selectDidPrsss()
                    self?.deleteItem()
                })
            })
            
        })
        self.updateHeaders()
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSelectMode = true
        selectDidPrsss()

        
    }
    
    
    init(dataSource: CollectionViewHeaderAndCellDataSource,
         collectionViewLayout: CustomImageFlowLayout = CustomImageFlowLayout(withHeader: true),
         configurator:GridConfigurator = GridConfigurator(), removeItems: @escaping ()->() )
    {
        super.init(dataSource: dataSource, collectionViewLayout: collectionViewLayout, configurator:configurator)
        dataSourceAPI?.uiViewController = self
        self.deleteItem = removeItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSelectMode = false
    }
    

    
    
    //MARK: - CollectionView Header
    
    //Mark: - Var
    
    
    func upadeToolBarCurrentStatus()
    {
        if configurator.canManualAppendAssets {
            guard let selectedItemsCount = photoGrid?.indexPathsForSelectedItems?.count else { return }
            centerBtn.title = selectedItemsCount == 0 ? "Add" : "Add To"
            centerBtn.isEnabled = true
        }
    }
    
    
    
    
    override var isSelectMode:Bool {
        didSet{
            let views = photoGrid?.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)

            upadeToolBarCurrentStatus()
            switch isSelectMode {
            
            case true:
                
                let cancelBtn = UIBarButtonItem(title: "Cancel", style: .done, target: self, action:  #selector(selectDidPrsss))
                navigationItem.rightBarButtonItems = [cancelBtn]


                    views?.forEach({ (view) in
                    if let selectableView = view as? SelectableHeaderReuseableView{
                        selectableView.selectBtn?.isHidden = false
                    }
                })
            default:
                navigationItem.rightBarButtonItems  = [UIBarButtonItem(title: "Select", style: .plain, target: self, action:  #selector(selectDidPrsss))]
                    dataProviderAPI?.emptySelection()
                    photoGrid?.deselectAll(animated: true)
                    views?.forEach({ (view) in
                    if let selectableView = view as? SelectableHeaderReuseableView{
                        selectableView.selectBtn?.isHidden = true
                        selectableView.select(false)
                    }
                })
            }

            dataProviderAPI?.update(selectMode: isSelectMode)
        }
    }
    
    ////// header

    
    func updateHeaders()
    {
        let indexPaths = photoGrid?.indexPathsForVisibleSupplementaryElements(ofKind:  UICollectionView.elementKindSectionHeader)
        indexPaths?.forEach({ (index) in
            if let view = photoGrid?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: index) as? SelectableHeaderReuseableView{
                view.update(index)
            }
            
        })
    }
    
    
    
    //////// tool bar
    
    override func leftBtn(_ sender: UIBarButtonItem) {
        print("left btn")
    }
    
    override func rightBtn(_ sender: UIBarButtonItem) {
        print("shoud remove")
//        removeItems()
        guard let itemsCount = photoGrid?.indexPathsForSelectedItems?.count else { return }
        let trashAlert = TrashAlertController(numberOfPhotos: itemsCount, isUserAlbum: configurator.canManualAppendAssets)
        trashAlert.photosDelegate = self
        self.present(trashAlert, animated: true, completion: nil)
    }
    
    override func centerBtn(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "Add To":
            guard let indexPaths = photoGrid?.indexPathsForSelectedItems ,let assets = dataProviderAPI?.dataObjects(at: indexPaths) else { return  }
            
            addToDidPress(assets)
            print("Add To did press")
        default:
            if let collectionLocalIdentifier = dataProviderAPI?.collectionLocalIdentifier {
                pushAsseterPicker(collectionLocalIdentifier)
            }
            print("Notttt Add To did press")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSelectMode {
            guard let asset = dataSource.dataProvider.dataObjects(at: [indexPath]).first else {
                return
            }
            didSelect(asset.localIdentifier)
            
            currentIdentifier = asset.localIdentifier
            selectedIndexPath = indexPath

            photoGrid?.deselectItem(at: indexPath, animated: false)
        }else{
            upadeToolBarCurrentStatus()
            functionToolBar?.enableAll()
        }
        
    }
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            (collectionView.indexPathsForSelectedItems?.count)! > 0 ? functionToolBar?.enableAll() : functionToolBar?.disableAll()
            upadeToolBarCurrentStatus()
        }
    
    deinit {
        print("deinit SelectableDeletablePhotoGridVC")
    }
    
    override func didSelectHeader(at indexPath: IndexPath?) {
        super.didSelectHeader(at: indexPath)
        upadeToolBarCurrentStatus()
    }
}
