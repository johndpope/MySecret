//
//  LocalAssetProviderSectioned.swift
//  MySecret
//
//  Created by Amir lahav on 01/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import DifferenceKit

class LocalAssetProviderSectioned<Z:Differentiable & MSAssetViewableProtocol & Object, F:ConfigurableCell & UICollectionViewCell, S:CollectionCellConfigurator<F,MSAssetViewableProtocol>>:LocalAssetProvider<Z, F, S>, DataProviderMultiSectionProtocol{
    
    

    
    
        
    let colletionType:MSAssetCollectionType
    let collectionSubtype:MSAssetCollectionSubtype
    
    required init(type: MSAssetCollectionType, subtype: MSAssetCollectionSubtype) {
        self.colletionType = type
        self.collectionSubtype = subtype
        super.init()
    }

    
    override func fetchPhotos(complition: (Bool) -> ()) {
        
        print("fetch from data provider")

        dataModel.fetchData(with: colletionType, subtype: collectionSubtype) { (result) in
            switch result{
                
            case .success(let presentableData):
                presentabelData = presentableData
                complition(true)
                
            case .error(_):
                print("error")
            }
        }
        
    }

    
    // arrange photos by:
    // one section
    // multiple section
    func arrange(assets:[Z], sectionType:SectionsType, complition:(Result<[Any]>)->())
    {
        var dic:[String:[Z]] = [:]
        var sortedArray:[[Z]] = []
        var data:[ArraySection<CollectionViewSection,Z>] = []
        
        // gloabal photos var
        presentabelData.removeAll()
        
        
        switch sectionType {
        case .multipleSections:
            assets.forEach({ (asset) in
                
                var key:String = ""
                if dic[key] != nil{
                    dic[key]!.append(asset)
                }else{
                    dic[key] = [asset]
                }
            })
            
            let sortedKeys = dic.keys.sorted(by: <)
            
            // appand all photos array to global photos array
            for (index,key) in sortedKeys.enumerated() {
                
                let sortedElemnts:[Z] = dic[key]!.sorted(by: {return
                    $0.creationDate < $1.creationDate
                })
                
                let section = ArraySection(model: CollectionViewSection(id: index, title: ""), elements: sortedElemnts)
                
                data.append(section)
                
                sortedArray.append(dic[key]!.sorted(by: {return
                    $0.creationDate < $1.creationDate
                }))
            }
            
            complition(Result.success(data))
            
        case .singleSection:
            
            let section = ArraySection(model: CollectionViewSection(id: 0, title: ""), elements: assets)
            complition(Result.success([section]))
        }
    }
    
    
    func getHeaderConfiguratorItem(at indexPath: IndexPath) -> HeaderConfigurator? {
        
        if indexPath.section > presentabelData.count - 1 { return nil }
        if indexPath.row > presentabelData[indexPath.section].elements.count - 1 { return nil }
        let header:PhotoHeaderModel = PhotoHeaderModel(title:presentabelData[indexPath.section].model.title ?? "")
        header.currentIndexPath = indexPath
        return PhotoHeaderConfig(item: header)
    }
    
    func getHeaderTitle(asset:MSAssetViewableProtocol) -> String
    {
        return asset.creationDate.toString(dateType: collectionSubtype)
    }
    
    func indexPath(to id: String) -> IndexPath? {
        for (sectionIndex, section) in presentabelData.enumerated(){
            for (itemIndex, item) in section.elements.enumerated(){
                if item.localIdentifier == id {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }

}


