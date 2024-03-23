//
//  AssetPreviewCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit
import AVFoundation

class AssetPreviewCell:UICollectionViewCell {
    
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var secondLabel: UILabel!
    
    func set(time:Double,
             asset:AVAsset?) {
        secondLabel.text = ""
        setPreviewImage(seconds: time, asset: asset)
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
    
    private func setPreviewImage(seconds:Double, asset:AVAsset?) {
        let previewTime:CMTime = .init(seconds: seconds, preferredTimescale: VideoEditorModel.timeScale)
        if let imageData = asset?.preview(time: previewTime)?.jpegData(compressionQuality: 0),
           let image = UIImage(data: imageData) {
            previewImageView.image = image
        } else {
            previewImageView.image = nil
        }
    }
}
