//
//  BaseButton.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class BaseButton:UIButton {
    static let buttonHeight:CGFloat = 40
    /// Description: 0 - .small / 1 - .primary
    @IBInspectable var style:Int = 0 {
        didSet {
            layer.cornerRadius = self.cornderRadious
        }
    }
    
    @IBInspectable var defaultConstraints:Bool = true
    
    @IBInspectable var cornderRadious:CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = self.cornderRadious
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                self.setupUI()
            })
        }
    }
}

extension BaseButton {
    enum BaseButtonType:Int {
        case primary = 0
        case smallGray = 1
        case smallLink = 2
    }
}

fileprivate extension BaseButton {
    func setupUI() {
        let style:BaseButtonType = .init(rawValue: self.style) ?? .primary
        let radius:CGFloat = cornderRadious == 0 && style != .smallGray ? (style == .primary ? 9 : 5) : 0
        if radius == layer.cornerRadius && radius != 0 {
            return
        }
        if cornderRadious == 0 && style != .smallGray {
            layer.cornerRadius = style == .primary ? 9 : 5
        }
        backgroundColor = style == .smallGray ? .clear : .link.withAlphaComponent(0.45)
        titleLabel?.font = .systemFont(ofSize: style == .primary ? Constants.Font.primaryButton.rawValue : Constants.Font.secondaryButton.rawValue, weight: style == .primary ? .medium : .medium)
        let tint:UIColor = style != .smallGray ? .type(.white) : (style == .smallGray ? .init(.greyText6) : .type(.white))
        titleLabel?.tintColor = tint
        titleLabel?.textColor = tint
        tintColor = tint
        setTitleColor(tint, for: .normal)
        setTitleColor(tint.withAlphaComponent(0.15), for: .disabled)
        if defaultConstraints {
            self.addConstaits(style == .primary ? [.height:BaseButton.buttonHeight] : [.width:40, .height:BaseButton.buttonHeight])
        }
        if style == .primary {
            layer.shadowColor = UIColor.init(.black).cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = .init(width: -1, height: 3)
            contentEdgeInsets.left = 15
            contentEdgeInsets.right = 15
            configuration?.contentInsets.leading = 15
            configuration?.contentInsets.trailing = 15
        }
        if style != .smallGray {
            layer.borderWidth = 0.5
            layer.borderColor = tint.withAlphaComponent(0.05).cgColor
        }
    }
}
