//
//  AssetDetailCollectionViewLayout.swift
//  MySecret
//
//  Created by Amir lahav on 26/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class AssetDetailCollectionViewLayout: UICollectionViewFlowLayout {

    
    override init() {
        super.init()
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }
 
    override var itemSize: CGSize
        {
        set {
            
        }
        get{
            return CGSize(width: self.collectionView!.frame.width, height: self.collectionView!.frame.height )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private var focusedIndexPath: IndexPath?
    
    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        focusedIndexPath = collectionView?.indexPathsForVisibleItems.first
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let indexPath = focusedIndexPath
            , let attributes = layoutAttributesForItem(at: indexPath)
            , let collectionView = collectionView else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        return CGPoint(x: attributes.frame.origin.x - collectionView.contentInset.left,
                       y: attributes.frame.origin.x - collectionView.contentInset.left)
    }
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        focusedIndexPath = nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }.compactMap(addParallaxToAttributes)
    }
    
    // We need to return true here so that everytime we scroll the collection view, the attributes are updated.
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    private func addParallaxToAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        
        let width = collectionView.frame.width
        let centerX = width / 2
        let offset = collectionView.contentOffset.x
        let itemX = attributes.center.x - offset
        let position = (itemX - centerX) / width
        let contentView = collectionView.cellForItem(at: attributes.indexPath)?.contentView
        let cell = collectionView.cellForItem(at: attributes.indexPath) as? Parallexable

        if abs(position) >= 1.0 {
            cell?.parallexView?.transform = .identity
            contentView?.transform = .identity
        } else if position < 1 && position > 0 {
            let transitionX = -(width * 0.10 * position)
            contentView?.transform = CGAffineTransform(translationX: transitionX, y: 0)
        } else if position < 0 && position > -1{
            let transitionX = -(width * 0.10 * position)
            cell?.parallexView?.transform = CGAffineTransform(translationX: transitionX, y: 0)
        }
        
        return attributes
    }
}
