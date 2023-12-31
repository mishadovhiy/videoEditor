//
//  loadUI_AssetParametersViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

//MARK: loadUI
fileprivate extension AssetParametersViewController {
    func loadUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AssetHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AssetHeaderCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
        }
        collectionView.addConstaits([.width:2000], superView: self.view)
        view.layer.layoutIfNeeded()
        loadAttachmentsSceletView()
    }
    
    func loadAttachmentsSceletView() {
        let data:[[MovieAttachmentProtocol]] = [assetData.media, assetData.text, assetData.songs]
        assetStackView.backgroundColor = .black
        data.forEach({
            AssetAttachmentView.create($0, delegate: self, to: assetStackView)
        })
    }
}

extension AssetParametersViewController:AssetAttachmentViewDelegate {
    func attachmentSelected(_ data: MovieAttachmentProtocol?) {
        
    }
    
    var vc: UIViewController {
        return self
    }
    
}
