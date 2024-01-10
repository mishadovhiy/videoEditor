//
//  loadUI_AssetParametersViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

//MARK: loadUI
extension AssetParametersViewController {
    func loadUI() {
        viewModel = .init()
        scrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AssetHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AssetHeaderCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
        }
        collectionView.constraints.first(where: {
            $0.firstAttribute == .width
        })!.constant = viewModel.assetData.duration// * AssetParametersViewController.durationWidthMultiplier
        view.layer.layoutIfNeeded()
        loadAttachmentsSceletView()
    }
    
    private func loadAttachmentsSceletView() {
        let data:[[MovieAttachmentProtocol]] = [viewModel.assetData.media, viewModel.assetData.text, viewModel.assetData.songs]
        assetStackView.backgroundColor = .black
        data.forEach({
            AssetAttachmentView.create($0, delegate: self, to: assetStackView)
        })
    }
}

