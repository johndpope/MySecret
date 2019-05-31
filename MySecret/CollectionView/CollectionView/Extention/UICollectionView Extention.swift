//
//  UICollectionView Extention.swift
//  MySecret
//
//  Created by Amir lahav on 13/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit


extension UICollectionView
{
    
    
    // register collection view cell
    func registerNib<T:UICollectionViewCell>(_:T.Type){
        let nib = UINib(nibName: T.nibName, bundle: Bundle(for: T.self))
        register(nib, forCellWithReuseIdentifier: T.uniqueIdentifier)
    }
    
    // register collection view header/footer
    func registerHeaderNib<T:UICollectionReusableView>(_:T.Type)
    {
        let nib = UINib(nibName: T.nibName, bundle: Bundle(for: T.self))
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.uniqueIdentifier)
    }
    
    func registerFooterNib<T:UICollectionReusableView>(_:T.Type)
    {
        let nib = UINib(nibName: T.nibName, bundle: Bundle(for: T.self))
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.uniqueIdentifier)
    }
    
    
    
    /// Iterates through all sections & items and selects them.
    func selectAll(animated: Bool) {
        (0..<numberOfSections).compactMap { (section) -> [IndexPath]? in
            return (0..<numberOfItems(inSection: section)).compactMap({ (item) -> IndexPath? in
                return IndexPath(item: item, section: section)
            })
            }.flatMap { $0 }.forEach { (indexPath) in
                selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
    }
    
    func selectItems(in section:Int, animated:Bool)
    {
       let allInedxs = (0..<numberOfItems(inSection: section)).compactMap({ (item) -> IndexPath? in
            return IndexPath(item: item, section: section)
        })
        allInedxs.forEach { (indexPath) in
            selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
    
    func deselectItems(in section:Int, animated:Bool)
    {
        let allInedxs = (0..<numberOfItems(inSection: section)).compactMap({ (item) -> IndexPath? in
            return IndexPath(item: item, section: section)
        })
        allInedxs.forEach { (indexPath) in

                deselectItem(at: indexPath, animated: animated)
        }
        
    }
    
    /// Deselects all selected cells.
    func deselectAll(animated: Bool) {
        indexPathsForSelectedItems?.forEach({ (indexPath) in
            deselectItem(at: indexPath, animated: animated)
        })
    }
    
    
}


public extension UICollectionView {
    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of UICollectionView.
    func reloadMe<C>(
        using stagedChangeset: StagedChangeset<C>,
        setData: (C) -> Void
        ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }
        
        for changeset in stagedChangeset {
            
            performBatchUpdates({
                setData(changeset.data)
                
                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted))
                }
                
                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted))
                }
                
                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated))
                }
                
                if !changeset.elementDeleted.isEmpty {
                    deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
                }
                
                if !changeset.elementInserted.isEmpty {
                    insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
                }
                
                if !changeset.elementUpdated.isEmpty {
                    reloadItems(at: changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
                }
            })
        }
    }
}
