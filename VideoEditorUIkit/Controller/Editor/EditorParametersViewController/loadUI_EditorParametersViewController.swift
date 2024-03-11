//
//  loadUI_AssetParametersViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

extension EditorParametersViewController {
    func loadUI() {
        viewModel = .init()
        viewModel?.reloadData = {
            self.dataChanged(reloadTable: $0)
        }
        scrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        scrollView.contentInset.left = view.frame.width / 2
        scrollView.contentInset.right = view.frame.width / 2
        collectionView.register(AssetHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AssetHeaderCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
        }
        updateAttachmantsStack()
        loadLeftHeader()
    }
    
    func updateAttachmantsStack() {
        let constraint = viewModel?.assetData.collectionWidth
        collectionView.constraints.first(where: {
            $0.identifier == "collectionWidth"
        })!.constant = CGFloat(constraint ?? 0) >= view.frame.width ? CGFloat(constraint ?? 0) : view.frame.width
        collectionView.layoutIfNeeded()
        view.layer.layoutIfNeeded()
        loadAttachmentsStacks()
    }
    
    private func loadAttachmentsStacks() {
        guard let viewModel else { return}
        let data:[([MovieAttachmentProtocol], InstuctionAttachmentType)] = [
            (viewModel.assetData.media, .media),
            (viewModel.assetData.text, .text),
            (viewModel.assetData.songs, .song)]
        print("attachments for editor: ", data)
        assetStackView.backgroundColor = .black
        data.forEach({ dataRow in
            if let stack = assetStackView.arrangedSubviews.first(where: { view in
                if let stack = view as? StackAssetAttachmentView,
                   stack.mediaType == dataRow.1
                {
                    return true
                } else {
                    return false
                }
            }) as? StackAssetAttachmentView
            {
                stack.updateView(dataRow.0)
            } else {
                StackAssetAttachmentView.create(dataRow.0, type: dataRow.1, delegate: self, to: assetStackView)
            }
        })
    }
    
    func loadLeftHeader() {
        assetStackView.arrangedSubviews.forEach {
            let superView = UIView()
            headersStack.addArrangedSubview(superView)
            superView.tag = $0.tag
            superView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftHeaderPressed(_:))))
        }
    }
        
    @objc private func leftHeaderPressed(_ sender:UITapGestureRecognizer) {
        assetStackView.arrangedSubviews.forEach {
            if let view = $0 as? StackAssetAttachmentView,
               view.tag == sender.view?.tag
            {
                view.addEmptyPressed()
            }
        }
    }
}

