//
//  TempLocalAssetProvider.swift
//  MySecret
//
//  Created by Amir lahav on 01/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import DifferenceKit



class LocalAssetProvider<Z:Differentiable & MSAssetViewableProtocol & Object, F:ConfigurableCell & UICollectionViewCell, S:CollectionCellConfigurator<F,MSAssetViewableProtocol>>:NSObject , DataProviderProtocol
{

    let dataModel = DataModel<Z>()


    override init() {
        super.init()
    }
    
    var presentabelData:[ArraySection<CollectionViewSection,Z>] = []
    
    var numberOfSections: Int {
        return presentabelData.count
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        let count = presentabelData[section].elements.count
        return count
    }
    
    func fetchPhotos(complition: (Bool) -> ()) {
        dataModel.fetchData(with: .moment, subtype: .dayMoment) { (result) in
            switch result {
            case .success(let assets):
                print("number of objects: \(assets.count)")
                    switch result{
                    case .success(let assets):
                        presentabelData = assets 
                        complition(true)
                    case .error(let err):
                        print(err)
                        complition(false)
                    }
            
                
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getCellConfiguratorItem(at indexPath: IndexPath) -> CellConfigurator? {
        let asset = presentabelData[indexPath.section].elements[indexPath.item]
        return S(item: asset)
    }
    
    func dataObjects(at indices: [IndexPath]) -> [MSAssetViewableProtocol] {

        // plasivo method... doesn't do nothing, just conforming to DataProviderMultiSectionSelectableProtocol
        
        let objects:[MSAssetViewableProtocol] = indices.map { (indexPath) in
            return presentabelData[indexPath.section].elements[indexPath.item]
        }
        
        return objects
    }
    
    
    func arrange(assets:[Z], complition:(Result<[Any]>)->())
    {
        // gloabal photos var
        presentabelData.removeAll()

        let section = ArraySection(model: CollectionViewSection(id: 0, title: ""), elements: assets)
        complition(Result.success([section]))
    }
    
    func getIndexOf(localIdentifier id:String) -> IndexPath?
    {
        print(presentabelData.count)
        if presentabelData.count == 0 { return nil }
        for i in 0...presentabelData.count - 1 {
            if presentabelData[i].elements.count == 0 { return nil }
            for j in 0...presentabelData[i].elements.count - 1{
                let asset = presentabelData[i].elements[j]
                if asset.localIdentifier == id {
                    return IndexPath(item: j, section: i)
                }
            }
        }
        return nil
    }
    
}
