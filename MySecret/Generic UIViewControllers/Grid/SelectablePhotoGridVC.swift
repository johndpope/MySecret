//
//  SelectablePhotoGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 22/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class SelectableDeletablePhotoGridVC: PhotoGridVC, GridSectionHeaderViewProtocol,CustomImageFlowLayoutProtocol {
    
    let safeAreaInsetsBottom = UIApplication.shared.windows[0].safeAreaInsets.bottom
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let bBar = functionToolBar { bBar.invalidateIntrinsicContentSize() }
        functionBarBottomConstraint.constant = size.width > size.height ? 32 : 44

    }
    
    /// provide data for this collection view
    /// can be from disk or user photo gallery
    
    private var dataProviderAPI:DataProviderMultiSectionSelectableProtocol? {
        guard let dataProvider = dataSourceAPI?.dataProvider as? DataProviderMultiSectionSelectableProtocol else {
            print("no data provider")
            return nil
        }
        return dataProvider
    }
    
    
    /// collection view data source, special for collection view with selectable headers.
    private var dataSourceAPI:CollectionViewHeaderAndCellDataSource?{
        guard let dataSource = dataSource as? CollectionViewHeaderAndCellDataSource  else {
            return nil
        }
        return dataSource
    }
    
    @objc func selectDidPrsss()
    {
        isSelectMode = !isSelectMode
        if isSelectMode {
            self.tabBarBackgroundBottoConstraint.constant = 53
            UIView.animate(withDuration: 0.15) {
                
                self.functionToolBar?.alpha = 1
                self.tabBarController?.tabBar.alpha = 0
                self.view.layoutIfNeeded()
                
            }
        }else{

            self.tabBarBackgroundBottoConstraint.constant = 49

            UIView.animate(withDuration: 0.15, animations: {[weak self] in
                self?.functionToolBar?.alpha = 0
                self?.tabBarController?.tabBar.alpha = 1
                self?.view.layoutIfNeeded()
                }, completion:{ (succ) in
                    self.functionToolBar?.disableAll()

            }
            )}

    }

    @objc func removeItems()
    {
        guard let indexPaths = photoGrid?.indexPathsForSelectedItems else {
            print("no itmes found")
            return
        }
        let sortedIndexPath = indexPaths.sorted(by: {$0>$1})
        dataProviderAPI?.removeAssets(at: sortedIndexPath, collectionView: photoGrid, complition: {[weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.photoGrid?.reloadItems(at: (self?.photoGrid?.indexPathsForVisibleItems)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self?.selectDidPrsss()
                })
            })
            
        })
        self.updateHeaders()
    }
    
 
    
    
    // force reload if needed
    // remove selection from section headers and make them unselected
    override func reload()
    {
        dataSourceAPI?.dataProvider.fetchPhotos(complition: {[weak self] (succ) in
            self?.photoGrid?.reloadData()
//            self?.dataProviderAPI?.emptySelection()
        })
    }
    
    init(dataSource: CollectionViewHeaderAndCellDataSource) {
        let layout = CustomImageFlowLayout(withHeader: true)
        super.init(dataSource: dataSource, collectionViewLayout: layout)
        layout.delegate = self
        photoGrid?.collectionViewLayout = layout
        dataSourceAPI?.uiViewController = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sectioned did load")
        isSelectMode = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSelectMode {
            didSelect(indexPath)
            photoGrid?.deselectItem(at: indexPath, animated: false)
        }else{
            functionToolBar?.enableAll()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.indexPathsForSelectedItems?.count)! > 0 ? functionToolBar?.enableAll() : functionToolBar?.disableAll()
        
    }
    
    
    //MARK: - CollectionView Header
    
    //Mark: - Var
    
    
    var isSelectMode:Bool = false {
        didSet{
            let views = photoGrid?.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
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

    
    //Mark: - Delegate
    
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
    
    
    
    func pinnedSection(at: IndexPath) {
        guard let header = photoGrid?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: at) as? GridSectionHeaderView else { return }
        header.blurView!.isHidden = false
    }
    
    func notPinnedSection(at: IndexPath) {
        guard let header = photoGrid?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: at) as? GridSectionHeaderView else { return }
        header.blurView!.isHidden = true
    }
    
    
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
        removeItems()
    }
    
}
