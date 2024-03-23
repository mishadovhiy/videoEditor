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
        let spaces = EditorParametersViewController.collectionViewSpace
        scrollView.contentInset.left = spaces.x
        scrollView.contentInset.right = spaces.y
        collectionView.register(AssetHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AssetHeaderCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
        }
        updateAttachmantsStack()
        loadLeftHeader()
        assetStackView.arrangedSubviews.last?.layer.cornerRadius(at: .bottom, value: 18)
        collectionView.backgroundColor = Constants.Color.trackColor
        scrollView.layer.masksToBounds = true
        scrollView.layer.cornerRadius = 18
    }
    
    func viewAppeared() {
        let spaces = EditorParametersViewController.collectionViewSpace
        scrollView.contentInset.left = spaces.x
        scrollView.contentInset.right = spaces.y
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
        let data:[([AssetAttachmentProtocol], InstuctionAttachmentType)] = [
            (viewModel.assetData.media, .media),
            (viewModel.assetData.text, .text),
            (viewModel.assetData.songs, .song)]
        print("attachments for editor: ", data)
      //  assetStackView.backgroundColor = .init(.secondaryBackground)
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
                StackAssetAttachmentView.create(dataRow.0, type: dataRow.1, totalVideoDuration: videoDuration, delegate: self, to: assetStackView)
            }
        })
    }
    
    func loadLeftHeader() {
        let images = [0:"movies", 3:"addImage", 2:"addText", 1:"addSound"]
        assetStackView.arrangedSubviews.forEach {
            let superView = UIView()
            headersStack.addArrangedSubview(superView)
            superView.tag = $0.tag
            let imageView = UIImageView(image: .init(named: images[$0.tag] ?? ""))
            superView.addSubview(imageView)
            superView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftHeaderPressed(_:))))
            if $0.tag == 0 {
                let label = UILabel()
                superView.addSubview(label)
                label.textColor = .init(.greyText)
                label.textAlignment = .center
                label.font = .type(.smallMedium)
                label.adjustsFontSizeToFitWidth = true
                label.addConstaits([.left:0, .right:0, .bottom:2])
            }
            imageView.tintColor = .type(.greyText)
            imageView.contentMode = .scaleAspectFill
            imageView.addConstaits([.centerX:0, .centerY:0, .width:13, .height:13])
        }
    }
}

