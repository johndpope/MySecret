//
//  SectionedPhotoGridVC.swift
//  MySecret
//
//  Created by Amir lahav on 01/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

class SectionedPhotoGridVC: PhotoGridVC, CustomImageFlowLayoutProtocol {
    
   
    init(dataSource: CollectionViewHeaderAndCellDataSource, collectionViewLayout: CustomImageFlowLayout = CustomImageFlowLayout(withHeader: true),configurator:GridConfigurator = GridConfigurator()) {
        super.init(dataSource: dataSource, collectionViewLayout: collectionViewLayout, configurator:configurator)
        collectionViewLayout.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
        
    func pinnedSection(at: IndexPath) {
        guard let header = photoGrid?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: at) as? GridSectionHeaderView else { return }
            header.pinned(true)
    }
    
    func notPinnedSection(at: IndexPath) {
        guard let header = photoGrid?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: at) as? GridSectionHeaderView else { return }
            header.pinned(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = dataSource.dataProvider.dataObjects(at: [indexPath]).first else {
            return
        }
            didSelect(asset.localIdentifier)
            photoGrid?.deselectItem(at: indexPath, animated: false)
    }

    
    deinit {
        print("deinit SectionedPhotoGridVC")
    }
    
}
