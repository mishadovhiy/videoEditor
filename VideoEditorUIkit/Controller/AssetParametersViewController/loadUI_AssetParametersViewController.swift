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
        viewModel?.reloadData = { [weak self] in
            self?.dataChanged()
        }
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
        updateAttachmantsStack()
    }
    
    func updateAttachmantsStack() {
        let constraint = viewModel?.assetData.collectionWidth
        collectionView.constraints.first(where: {
            $0.identifier == "collectionWidth"
        })!.constant = CGFloat(constraint ?? 0) >= view.frame.width ? CGFloat(constraint ?? 0) : view.frame.width
        collectionView.backgroundColor = .red
        collectionView.layoutIfNeeded()
        // * AssetParametersViewController.durationWidthMultiplier
        view.layer.layoutIfNeeded()
        loadAttachmentsStacks()
    }
    
    private func loadAttachmentsStacks() {
        assetStackView.arrangedSubviews.forEach {
            if !($0 is UICollectionView) {
                $0.removeFromSuperview()
            }
        }
        guard let viewModel else { return}
        let data:[[MovieAttachmentProtocol]] = [viewModel.assetData.media, viewModel.assetData.text, viewModel.assetData.songs]
        assetStackView.backgroundColor = .black
        data.forEach({
            AssetAttachmentView.create($0, delegate: self, to: assetStackView)
        })
    }
}

