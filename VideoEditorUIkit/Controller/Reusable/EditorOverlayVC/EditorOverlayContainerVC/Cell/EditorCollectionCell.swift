//
//  EditorCollectionCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class OverlayTextFieldCell:UICollectionViewCell {
    
    @IBOutlet weak var textField: BaseTextField!
}

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
        if let textColor {
            titleLabel.textColor = textColor
            imageView.tintColor = textColor
        }
        self.textFieldEditing = textFieldEditing
        titleLabel.text = item.title
        self.screenHeight = type
        if let imageData = item.imageData,
           let image = UIImage(data: imageData) {
            imageView.image = image
            //imageView.isHidden = false//.superview?.isHidden = false
        } else if let imageString = item.image,
                  let imageRes = UIImage.init(named: imageString) {
          //  imageView.setImage(item.image, superView: imageView)
            imageView.image = imageRes
        } else {
            imageView.image = nil
        }
        backgroundColor = item.backgroundColor
        setupUI()
        if type != .big {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 25).isActive = true
        }
    }
}

// MARK: - setupUI
fileprivate extension EditorCollectionCell {
    private func setupUI() {
        titleLabel.font = .type(.small)
        contentView.layer.drawLine([
            .init(x: -5, y: 5),
                .init(x: -5, y: contentView.frame.height - 10)
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
