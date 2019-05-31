//
//  AlbumCoordinator.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AlbumCoordinator : TabCoordinator {

    var reload: () -> () = { }
    
    func update() {
        albumViewController?.fetch()
        photosContrller?.reload()
    }
    
    var image: UIImage? = UIImage(named: "AlbumTabIcon")
    
    var pressenter: UINavigationController
    var name:String = "Album"
   
    weak var albumViewController:MSSelectableCreateableEditableAlbumGridVC?
    weak var photosContrller:SelectableDeletablePhotoGridVC?
    weak var navigationPickerContainer:UINavigationController?

    init(pressenter:UINavigationController) {
        self.pressenter = pressenter
        pressenter.navigationBar.prefersLargeTitles = true
    }
    
    
    /// tabcoordinator start function push album contoller
    //
    func start() {
        
        let dataProvider = LocalCollectionAssetEditableProvider<MSLocalAssetCollection, AlbumCollectionViewCell, AlbumFolderConfig>()
        let dataSource = CollectionViewSectionedDataSource(dataProvider: dataProvider)
        
        let avc = MSSelectableCreateableEditableAlbumGridVC(dataSource: dataSource)
        avc.title = "Albums"
        avc.didSelectAlbum = push
        avc.didFinishCreateNewAlbumWithName = pushSelectableGrid
        pressenter.pushViewController(avc, animated: false)
        albumViewController = avc
        
    }
    
    // push album grid controller
    // always without large title
    func push(to id:String)
    {
        let dataProvider = LocalAssetProviderSectionedDeleteable<MSLocalAsset, BasicPhotoCell, PhotoCellConfig>(localIdentifier:id)
        let dataSource = CollectionViewHeaderAndCellDataSource(dataProvider: dataProvider)
        
        let canManualAppend = MSLocalAssetCollection.isAddable(localIdentifier: id)
        let albumName = MSLocalAssetCollection.albumName(localIdentifier: id) ?? "Photos"
        let config = GridConfigurator(displayMode: .never, canManualAppendAssets: canManualAppend)
        
        let pvc = SelectableDeletablePhotoGridVC(dataSource: dataSource, configurator:config, removeItems:reload)
        pvc.fetchAndScroll(to: "")
        pvc.collectionTitle = albumName
        pvc.didSelect = {[weak self] (assetId) in
            self?.pushDetail(album: id, assetLocalIdentifier: assetId, isUserAlbum: canManualAppend)
        }
        pvc.pushAsseterPicker = pushSelectableGrid
        pvc.addToDidPress = addTo
       
        let back = UIBarButtonItem().with(itemType: .back, target: self, action: #selector(unwind))
        
        pvc.navigationItem.leftBarButtonItem = back
        pressenter.pushViewController(pvc, animated: true)
        photosContrller = pvc
    }
    
    // album picker after use choose assets to add to other album or new one
    func addTo(assets:[MSAssetViewableProtocol])
    {
        let assetsIds:[String] = assets.map { return $0.localIdentifier }
        print("add to assets")
        let dataProvider = LocalUserCollectionAssetProvider<MSLocalAssetCollection, AlbumCollectionViewCell, AlbumFolderConfig>()
        let dataSource = CollectionViewDataSource(dataProvider: dataProvider, preferedCellSize: .detail)
        
        let avc = MSUserAlbumPickerGridVC(dataSource: dataSource)
        let nc = UINavigationController(rootViewController: avc)
        avc.title = "My Albums"
        avc.didSelectAlbum = {[weak self] (albumName) in
            self?.didFinishPick(assetsIds: assetsIds, albumName: albumName)
        }
        avc.didFinishCreateNewAlbumWithName = {[weak self] (albumName) in
            self?.didFinishPick(assetsIds: assetsIds, albumName: albumName)
        }
        
        avc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(popPicker))
        hideTabbar(true)
        pressenter.present(nc, animated: true, completion: {[weak self] in
            self?.navigationPickerContainer = nc
        })
    }
    
    func pushSelectableGrid(albumName:String){
        
        let dataProvider = LocalAssetProviderSectionedDeleteable<MSLocalAsset, BasicPhotoCell, PhotoCellConfig>(type: .moment, subtype: .dayMoment)
        let dataSource = CollectionViewHeaderAndCellDataSource(dataProvider: dataProvider)

        
        let config = GridConfigurator(displayMode: .never, canManualAppendAssets: false, hideToolbarBackground:true)
        let assetPicker = SelectablePhotoGridVC(dataSource: dataSource, configurator: config)
        let nc = UINavigationController(rootViewController: assetPicker)

        assetPicker.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(popPicker))
        assetPicker.fetchAndScroll(to: "")
        assetPicker.collectionTitle = "Photos"
        assetPicker.setAlbum(name: albumName)
        assetPicker.didPickAsset = {[weak self] (assets, albumName)  in
            let assetsIds:[String] = assets.map { return $0.localIdentifier }
            self?.didFinishPick(assetsIds: assetsIds, albumName: albumName)
        }
        pressenter.present(nc, animated: true) {[weak self] in
            self?.navigationPickerContainer = nc
        }
        hideTabbar(true)
    }
    
    // user did finish pick photos and need to add to album
    // if album is alrady created then just append asstes
    // else create new album with album name
    // param: albumName - for new album will be album name and for old album will be local identifier
    func didFinishPick(assetsIds:[String] ,albumName:String)
    {
        
        MSPhotoLibrary.shared().performChanges({ (realm) in
            
            let assetsToSave = MSLocalAsset.fetchAssets(assetsIds, realm: realm)
            var changeRequest:MSLocalAssetCollectionChangeRequest? = nil
            
            //// if album is already created just add new assets
            if let collection = MSLocalAssetCollection.fetchAssetCollection(with: albumName, realm: realm).first {
                changeRequest = MSLocalAssetCollectionChangeRequest(for: collection, realm: realm)
                
                //// if not, create new album
            }
            else{
                print("didnt find album with name: \(albumName)")
                changeRequest = MSLocalAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName, realm:realm)
            }
            // append asset to asset collection
            
            changeRequest?.append(assets: assetsToSave, realm:realm,  completion: { (result) in
                switch result {
                case .success(let t):
                    print(t)
                    DispatchQueue.main.async {
                        self.reload()
                    }
                case .error(let err):
                    print(err)
                }
            })
            
        }) { (success) in
            print("finish save photossss")
            DispatchQueue.main.async {
                self.popPicker()
            }
        }
    }

    
    @objc func popPicker()
    {
        hideTabbar(false)
        navigationPickerContainer?.dismiss(animated: true, completion: {[weak self] in
            self?.navigationPickerContainer = nil
        })
    }
    
    @objc func popVC()
    {
        pressenter.popViewController(animated: true)
    }
    
    @objc func unwind()
    {
        pressenter.popViewController(animated: true)
    }
    
    @objc func unwindDetail()
    {
        pressenter.pop(type: .fade, subType:  CATransitionSubtype.fromLeft)
    }
    
    // push detail view controller
    // current data provider base on user gallery photos
    // need to change to real provider
    func pushDetail(album id:String, assetLocalIdentifier:String, isUserAlbum:Bool)
    {
        print("push to \(id)")
        let dataProvider = LocalAssetProviderSectionedDeleteable<MSLocalAsset, DetailPhotoCell, DetailPhotoCellConfig>(localIdentifier:id)
        let dataSource = CollectionViewDataSource(dataProvider: dataProvider, preferedCellSize: .detail)
        let config = GridConfigurator(displayMode: .never, canManualAppendAssets: isUserAlbum)
        let vc = PhotoDetailViewController(dataSource: dataSource, scrollTo:assetLocalIdentifier, configurator:config)
        vc.deleteItem = reload
//        vc.dismissAtIndexPath = dismiss
        let back =  UIBarButtonItem().with(itemType: .back, target: self, action: #selector(unwind))
        pressenter.delegate = vc.transitionController
        vc.transitionController.toDelegate = vc
        vc.transitionController.fromDelegate = photosContrller
        
        vc.title = "Detail"
        vc.navigationItem.leftBarButtonItem = back
        print("start presenting detail vc")
        pressenter.pushViewController(vc, animated: true)
    }
    
    func hideTabbar(_ hide:Bool){
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.pressenter.tabBarController?.tabBar.alpha = hide ? 0.0 : 1.0
        }
    }
    
}
