//
//  SelectableDeletableAddablePhotoGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 04/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit


class SelectableDeletableAddablePhotoGridVC: SelectableDeletablePhotoGridVC {
    
    @objc func addUserPhotos()
    {
        tapAddUserPhotos()
    }
    var tapAddUserPhotos:()->() = {}
    
    
    override var isSelectMode:Bool {
        didSet{
            let views = photoGrid?.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
            switch isSelectMode {
                
            case true:
                
                let add =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUserPhotos))
                let cancelBtn = UIBarButtonItem(title: "Cancel", style: .done, target: self, action:  #selector(selectDidPrsss))
                navigationItem.rightBarButtonItems = [cancelBtn, add]
                
                
                views?.forEach({ (view) in
                    if let selectableView = view as? SelectableHeaderReuseableView{
                        selectableView.selectBtn?.isHidden = false
                    }
                })
            default:
                
                let add =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUserPhotos))
                let select = UIBarButtonItem(title: "Select", style: .plain, target: self, action:  #selector(selectDidPrsss))
                navigationItem.rightBarButtonItems  = [select, add]
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

    
    deinit {
        print("deinit SelectableDeletableAddablePhotoGridVC")
    }
    
}
