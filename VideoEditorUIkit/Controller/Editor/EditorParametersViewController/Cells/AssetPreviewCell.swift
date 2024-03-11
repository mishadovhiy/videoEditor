//
//  AssetPreviewCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

class AssetPreviewCell:UICollectionViewCell {
    
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var secondLabel: UILabel!
    
    func set(previewImage:Data?, secondText:String) {
        secondLabel.text = secondText
        if let previewImage {
            previewImageView.image = .init(data: previewImage)
        } else {
            previewImageView.image = nil
        }
        previewImageView.constraints.first(where: {$0.firstAttribute == .width})?.constant = MovieGeneralParameterList.AssetsData.cellWidth
        previewImageView.layoutIfNeeded()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        previewImageView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }
}
