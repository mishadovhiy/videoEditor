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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        contentView.layer.drawLine([
            .init(x: -5, y: 12),
                .init(x: -5, y: contentView.frame.height - 26)
        ], color: .init(.separetor), name: "LeftSeparetor")
        titleLabel.textColor = .init(.white)
        titleLabel.font = .type(.small)
    }
    
    func set(_ item: EditorOverlayVC.OverlayCollectionData) {
        titleLabel.text = item.title
        imageView.setImage(item.image, superView: imageView.superview)
        backgroundColor = item.backgroundColor
    }
}
