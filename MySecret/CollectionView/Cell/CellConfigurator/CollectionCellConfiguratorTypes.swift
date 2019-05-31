//
//  CollectionCellConfiguratorTypes.swift
//  MySecret
//
//  Created by Amir lahav on 19/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//


// Collection Cell Configurator type
// holding together the data and cell view

typealias TinyCellConfig = CollectionCellConfigurator<TinyCell, MSAssetViewableProtocol>

typealias PhotoCellConfig = CollectionCellConfigurator<BasicPhotoCell, MSAssetViewableProtocol>

typealias DetailPhotoCellConfig = CollectionCellConfigurator<DetailPhotoCell, MSAssetViewableProtocol>

typealias PhotoHeaderConfig = CollectionHeaderConfigurator<GridSectionHeaderView, MSHeaderViewableProtocol>

typealias AlbumFolderConfig = CollectionCellConfigurator<AlbumCollectionViewCell, MSLocalAssetCollection>

typealias AlbumHeaderConfig = CollectionHeaderConfigurator<AlbumCollectionHeaderView, MSHeaderViewableAlbumProtocol>
