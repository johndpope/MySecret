//
//  CustomImageFlowLayout.swift
//  Photo Gallery
//
//  Created by amir lahav on 1.10.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import UIKit


protocol CustomImageFlowLayoutProtocol:class {
    func pinnedSection(at:IndexPath)
    func notPinnedSection(at:IndexPath)
}

class CustomImageFlowLayout: UICollectionViewFlowLayout {
    
    let insets = UIApplication.shared.windows[0].safeAreaInsets

    
    var itemsPerRowPortrait:Int = 4
    var itemsPerRowLandscape:Int = 7
    
    let collectionViewHeaderHight:CGFloat = 40
    weak var delegate:CustomImageFlowLayoutProtocol?
    var barHeight: CGFloat!
    
    var isPortrait: Bool {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            return true
            
        case .faceUp, .faceDown, .portraitUpsideDown:
            // Check the interface orientation
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            switch interfaceOrientation{
            case .portrait:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }

    
    init(withHeader header: Bool = true, itemsPerRowPortrait:Int = 4,  itemsPerRowLandscape:Int = 7)
    {

        self.itemsPerRowPortrait = itemsPerRowPortrait
        self.itemsPerRowLandscape = itemsPerRowLandscape
        super.init()
        minimumInteritemSpacing = 1.0
        minimumLineSpacing = 1.0
        setupLayout(withHeader: header)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout(withHeader: true)
    }
    
    var focusedIndexPath: IndexPath?
    
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        
        guard let oldCenter = focusedIndexPath else {
            return proposedContentOffset
        }
        
        let attrs =  collectionView.layoutAttributesForItem(at: oldCenter)
        
        let newOriginForOldIndex = attrs?.frame.origin
        
        return newOriginForOldIndex ?? proposedContentOffset
    }
    
    
    
    override var itemSize: CGSize
        {
        set {}
        get{
            let pedding:CGFloat = minimumLineSpacing
            var row:CGFloat!
            var numOfColumns: CGFloat {
                

                if isPortrait { return CGFloat(itemsPerRowPortrait)} else {return CGFloat(itemsPerRowLandscape)}


            }
            let itemWidth = ((UIScreen.main.bounds.width - 2 * UIApplication.shared.windows[0].safeAreaInsets.left - (numOfColumns - 1) * pedding) / numOfColumns)
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func setupLayout(withHeader header:Bool) {
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
        headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: header ? collectionViewHeaderHight : 0)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // Helpers
        let sectionsToAdd = NSMutableIndexSet()
        var newLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for layoutAttributesSet in layoutAttributes {
            if layoutAttributesSet.representedElementCategory == .cell {
                // Add Layout Attributes
                newLayoutAttributes.append(layoutAttributesSet)
                
                // Update Sections to Add
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
                
            } else if layoutAttributesSet.representedElementCategory == .supplementaryView {
                // Update Sections to Add
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
            }
        }
        
        for section in sectionsToAdd {
            let indexPath = IndexPath(item: 0, section: section)
            
            if let sectionAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                newLayoutAttributes.append(sectionAttributes)
            }
        }
        
        return newLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }

        guard let boundaries = boundaries(forSection: indexPath.section) else { return layoutAttributes }
        guard let collectionView = collectionView else { return layoutAttributes }
        
        // Helpers
        let contentOffsetY = collectionView.contentOffset.y
        var frameForSupplementaryView = layoutAttributes.frame
        
        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height
        
        var bottom:CGFloat = 0
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            barHeight = 32 - collectionViewHeaderHight
            bottom = insets.bottom > 0 ? 12 : 0

        case .portrait,.faceDown,.faceUp, .unknown:
            
            barHeight = 64 - collectionViewHeaderHight
            
            bottom = insets.bottom > 0 ? 24 : 0

        }
                
        if isPortrait { barHeight = 64 - collectionViewHeaderHight + bottom } else {barHeight =  32 - collectionViewHeaderHight + bottom }

        
        
        if contentOffsetY < minimum - barHeight {
            frameForSupplementaryView.origin.y = minimum
            delegate?.notPinnedSection(at: indexPath)

        } else if contentOffsetY > maximum - barHeight {
            frameForSupplementaryView.origin.y = maximum
            delegate?.pinnedSection(at: indexPath)

//            print("contentOffsetY: \(contentOffsetY) > maximum \(maximum - barHeight), \(frameForSupplementaryView.origin.y), \(indexPath)")

        } else {
            frameForSupplementaryView.origin.y = contentOffsetY + barHeight
            delegate?.pinnedSection(at: indexPath)
//            print("\(maximum), \(minimum), \(frameForSupplementaryView.origin.y), \(indexPath)")
        }
        
        layoutAttributes.frame = CGRect(x: frameForSupplementaryView.minX, y: frameForSupplementaryView.minY + collectionViewHeaderHight, width: frameForSupplementaryView.width, height: frameForSupplementaryView.height)
        
        return layoutAttributes
    }
    
    // MARK: - Helper Methods
    
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        // Helpers
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))
        
        // Exit Early
        guard let collectionView = collectionView else { return result }
        
        // Fetch Number of Items for Section
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        // Exit Early
        guard numberOfItems > 0 else { return result }
        
        if let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
            let lastItem = layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: section)) {
            result.minimum = firstItem.frame.minY
            result.maximum = lastItem.frame.maxY
            
            // Take Header Size Into Account
            result.minimum -= headerReferenceSize.height
            result.maximum -= headerReferenceSize.height
            
            // Take Section Inset Into Account
            result.minimum -= sectionInset.top
            result.maximum += (sectionInset.top + sectionInset.bottom)
        }
        
        return result
    }
}



class tinyAssetGridLayout:CustomImageFlowLayout
{
    override init(withHeader header: Bool = true, itemsPerRowPortrait: Int, itemsPerRowLandscape: Int) {
        super.init(withHeader: header, itemsPerRowPortrait: itemsPerRowPortrait, itemsPerRowLandscape: itemsPerRowLandscape)

        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        
    }
    
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
