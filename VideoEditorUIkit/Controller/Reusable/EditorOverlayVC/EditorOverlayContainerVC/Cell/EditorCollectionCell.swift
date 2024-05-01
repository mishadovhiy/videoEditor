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
    
    private var screenHeight:EditorOverlayContainerVC.OverlaySize?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            return
        }
    }
    
    var textFieldEditing:Bool = false
    func set(_ item: EditorOverlayVC.OverlayCollectionData, type:EditorOverlayContainerVC.OverlaySize? = nil, textFieldEditing:Bool, textColor:UIColor?) {
        backgroundColor = item.backgroundColor ?? .clear
        titleLabel.textColor = .type(item.buttonColor != nil ? .white : .greyText)
        let resultColor = (item.textColor ?? (item.buttonColor != nil ? .white : nil)) ?? (textColor ?? .type(.greyText))
        titleLabel.textColor = resultColor
        imageView.tintColor = item.buttonColor == nil ? resultColor : .type(.greyText)

        titleLabel.backgroundColor = item.buttonColor ?? .clear
        titleLabel.layer.cornerRadius = 4
        titleLabel.layer.masksToBounds = true
        
        self.textFieldEditing = textFieldEditing
        titleLabel.text = item.title
        self.screenHeight = type
        if let imageData = item.imageData,
           let image = UIImage(data: imageData)
        {
            imageView.image = image
        } else if let imageString = item.image,
                  let imageRes = UIImage.init(named: imageString) {
            if let imageData = item.imageData,
               let secondImage = UIImage(data: imageData)
            {
                imageView.image = imageRes.combineImages(image2: secondImage, imageSize: .init(width: 30, height: 30))
            } else {
                imageView.image = imageRes
            }
        } else {
            imageView.image = nil
        }
        
        setupUI()
    }
}

// MARK: - setupUI
fileprivate extension EditorCollectionCell {
    private func setupUI() {
        titleLabel.font = .type(.small)
        contentView.layer.drawLine([
            .init(x: 0, y: 0),
            .init(x: 0, y: contentView.frame.height)
        ], color: .init(.separetor), name: "LeftSeparetor")
    }
    
    private func updateConstraint() {
        if let stack = titleLabel.superview as? UIStackView,
           let constant = stack.constraints.first(where: {$0.firstAttribute == .height}),
           let imageConstant = imageView.constraints.first(where: {
               $0.firstAttribute == .width
           })
        {
            var type = screenHeight
            if textFieldEditing {
                type = .middle
            }
            switch type {
            case .big:
                imageConstant.constant = 180
                constant.constant = 200
            case .middle:
                imageConstant.constant = 30
                constant.constant = 50
            default:
                constant.constant = 32
                imageConstant.constant = 20
            }
            
        }
        titleLabel.superview?.layoutIfNeeded()
        titleLabel.superview?.superview?.layoutIfNeeded()
        imageView.layoutIfNeeded()
    }
}
