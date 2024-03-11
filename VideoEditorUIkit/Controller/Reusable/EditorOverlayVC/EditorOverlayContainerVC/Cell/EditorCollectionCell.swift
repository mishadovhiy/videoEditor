//
//  EditorCollectionCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class EditorCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    func set(_ item: EditorOverlayVC.OverlayCollectionData) {
        titleLabel.text = item.title
        imageView.setImage(item.image, superView: imageView.superview)
    }
}
