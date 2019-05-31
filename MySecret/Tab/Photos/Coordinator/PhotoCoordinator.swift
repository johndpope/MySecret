//
//  PhotosCoordinator.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PhotosCoordinator : NSObject, TabCoordinator, UINavigationControllerDelegate {
    
    // reload transmit to all tab coordinator to reload content cuz somthing in model has chenge
    // added, delete, changed
    var reload: () -> () = { }
    
    // main navigation controller
    var pressenter: UINavigationController
    
    weak var collectionContrller:SectionedPhotoGridVC?
    weak var photosContrller:SelectableDeletableAddablePhotoGridVC?
    weak var importAssetsViewController:ImportUserPhotosGridVC?
    weak var coveredNavigationController:UINavigationController?
    var name:String = "Photos"

    init(pressenter:UINavigationController) {
        self.pressenter = pressenter
        super.init()
        self.pressenter.delegate = self
    }
    
    
    // MARK: ViewControllers actions
    
    // coordinator start point
    // push cluseter moment
    // every section represnet one calander month
    func start() {
        
        let dataProviderYear = LocalAssetProviderSectioned<MSLocalAsset, TinyCell, TinyCellConfig>(type: .moment, subtype: .monthMoment)
        let dataSourceYear = CollectionViewHeaderAndCellDataSource(dataProvider: dataProviderYear)
        let layout = tinyAssetGridLayout(itemsPerRowPortrait: 10, itemsPerRowLandscape: 21)
        let monthVc = SectionedPhotoGridVC(dataSource: dataSourceYear, collectionViewLayout: layout)
        monthVc.fetchAndScroll(to: "")
        monthVc.collectionTitle = "Collections"
        monthVc.didSelect = pushPhotoGridVC
        pressenter.pushViewController(monthVc, animated: false)
        pushPhotoGridVC(imageLocalIdentifier: "")
        collectionContrller = monthVc
    }
    
    // push photo grid view controller and scroll
    // param imageLocalIdentifier: image id presed in previous grid controller
    func pushPhotoGridVC(imageLocalIdentifier id:String)
    {
        let dataProvider = LocalAssetProviderSectionedDeleteable<MSLocalAsset, BasicPhotoCell, PhotoCellConfig>(type: .moment, subtype: .dayMoment)
        let dataSource = CollectionViewHeaderAndCellDataSource(dataProvider: dataProvider)
        let config = GridConfigurator(displayMode: .always, canManualAppendAssets: false)
        let pvc = SelectableDeletableAddablePhotoGridVC(dataSource:dataSource,configurator:config, removeItems:reload)
        pvc.fetchAndScroll(to: id)
        pvc.collectionTitle = "Photos"
        pvc.didSelect = pushDetail
        pvc.tapAddUserPhotos = {
            MSPhotoLibrary.shared().checkPhotoLibraryPermission(completion: {[weak self] (result) in
                switch result{
                case .success(_):
                    print("has permisssion")
                    DispatchQueue.main.async {
                        self?.pushPhotoGalleryImporter()
                    }
                case .error(_):
                    print("didnt get permission")
                }
            })
        }
        pvc.addToDidPress = addAssetsToAlbum
        let back = UIBarButtonItem().with(itemType: .back, target: self, action: #selector(unwindFade))
        pvc.navigationItem.leftBarButtonItem = back
        pressenter.push(vc: pvc, type: .fade)
        photosContrller = pvc
    }

    // push galley photo importer picker
    // must have permission to user gallery
    @objc func pushPhotoGalleryImporter()
    {
        let dataProvider = GalleryPhotosProvider()
        let dataSource = CollectionViewDataSource(dataProvider: dataProvider, preferedCellSize: .thumbnail)
        
        let importPhotosVC = ImportUserPhotosGridVC(dataSource:dataSource)
        
        let imaporterNavigationController = UINavigationController(rootViewController: importPhotosVC)
        imaporterNavigationController.modalPresentationStyle = .overCurrentContext
        importPhotosVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(popCoveredNavigationController))
        importPhotosVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(importPhotos))
        importPhotosVC.collectionTitle = "Select Items"
        hideTabbar(true)
        pressenter.present(imaporterNavigationController, animated: true) {[weak self] in
            self?.coveredNavigationController = imaporterNavigationController
        }
        importAssetsViewController = importPhotosVC
    }
    
    func hideTabbar(_ hide:Bool){
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.pressenter.tabBarController?.tabBar.alpha = hide ? 0.0 : 1.0
        }
    }
    
    @objc func popCoveredNavigationController()
    {
        hideTabbar(false)
        self.coveredNavigationController?.dismiss(animated: true, completion: {[weak self] in
            self?.coveredNavigationController = nil
        })
    }
    
    
    // push detail view controller
    // current data provider base on user gallery photos
    // need to change to real provider
    func pushDetail(id:String)
    {
        print("push to \(id)")
        let dataProvider = LocalAssetProviderSectionedDeleteable<MSLocalAsset, DetailPhotoCell, DetailPhotoCellConfig>(type: .smartAlbum, subtype: .albumCameraRoll)
        let dataSource = CollectionViewDataSource(dataProvider: dataProvider, preferedCellSize: .detail)
        let config = GridConfigurator(displayMode: .never, canManualAppendAssets: false)
        let vc = PhotoDetailViewController(dataSource: dataSource, scrollTo:id, configurator:config)
        pressenter.delegate = vc.transitionController
        vc.transitionController.toDelegate = vc
        vc.transitionController.fromDelegate = photosContrller
        // to do, dismiss controller and scroll to image
        //        vc.dismissAtIndexPath = dismiss
        vc.deleteItem = {[weak self] in
            self?.reload()
        }
        let back = UIBarButtonItem().with(itemType: .back, target: self, action: #selector(unwind))
        vc.dismissAtIndexPath = currentImage
        vc.navigationItem.leftBarButtonItem = back
        print("start presenting detail vc")
        pressenter.pushViewController(vc, animated: true)
    }
    
    
    // album picker
    // after user pick assets
    // push album picker on top of photo grid
    // to do: custom anvigation contorller with asstet on top
    func addAssetsToAlbum(with assets:[MSAssetViewableProtocol])
    {
        let assetsIds:[String] = assets.map { return $0.localIdentifier }
        let dataProvider = LocalUserCollectionAssetProvider<MSLocalAssetCollection, AlbumCollectionViewCell, AlbumFolderConfig>()
        let dataSource = CollectionViewDataSource(dataProvider: dataProvider)
        
        let avc = MSUserAlbumPickerGridVC(dataSource: dataSource)
        let imaporterNavigationController = UINavigationController(rootViewController: avc)
        
        avc.title = "Albums"
        avc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(popCoveredNavigationController))
        avc.didSelectAlbum = {[weak self] (albumName) in
            self?.didFinishPick(assetsIds: assetsIds, albumName: albumName)
        }
        avc.didFinishCreateNewAlbumWithName = {[weak self] (albumName) in
            self?.didFinishPick(assetsIds:  assetsIds, albumName: albumName)
        }
        pressenter.present(imaporterNavigationController, animated: true) {[weak self] in
            self?.coveredNavigationController = imaporterNavigationController
        }
        //        pressenter.push(vc: avc, type: .moveIn, subType: .fromTop)
        
    }
    
    
    // user did finish pick photos and need to add to album
    // if album is alrady created then just append asstes
    // else create new album with album name
    // param: albumName - for new album will be album name and for old album will be local identifier
    func didFinishPick(assetsIds:[String],albumName:String)
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

                case .error(let err):
                    print(err)
                }

            })
            
        }) { (success) in
            print("finish save photossss")
            DispatchQueue.main.async {
                self.popCoveredNavigationController()
                self.reload()
            }
        }
    }

    
    // user pick photos to import from user gallery
    @objc func importPhotos()
    {
        guard let indexs = importAssetsViewController?.photoGrid?.indexPathsForSelectedItems,
            let realPhotos = importAssetsViewController?.dataSource.dataProvider.dataObjects(at: indexs) as? [MSAssetViewableProtocol & Saveable] else {
            popVC()
            return
        }

        AssetSaver.shared().save(assets: realPhotos, completion: {[weak self] in
            print("save photo comlete")
            self?.reload()
            self?.popCoveredNavigationController()

        })
    }
    

    // MARK: Conform to TabCoordinator
    
    var image: UIImage?  = UIImage(named: "PhotoTabIcon")

    func update()
    {
        print("update")
        collectionContrller?.reload()
        photosContrller?.reload()
    }
    
    func currentImage(id:String)
    {
        photosContrller?.currentIdentifier = id
        collectionContrller?.currentIdentifier = id
    }

    
   
    
    // MARK: Coordinator presenter actions
    @objc func popVC()
    {
        pressenter.pop(type: .reveal, subType: .fromBottom)
    }
    
    @objc func unwind()
    {
        pressenter.popViewController(animated: true)
    }
    
    @objc func unwindFade()
    {
        pressenter.pop(type: .fade)
    }
    
    
    
}
