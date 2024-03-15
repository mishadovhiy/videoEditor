//
//  BaseButton.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class BaseButton:UIButton {
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
        if cornderRadious == 0 && style != .smallGray {
            layer.cornerRadius = style == .primary ? 9 : 5
        }
        backgroundColor = style == .smallGray ? .clear : .link
        titleLabel?.font = .systemFont(ofSize: style == .primary ? Constants.Font.primaryButton.rawValue : Constants.Font.secondaryButton.rawValue, weight: style == .primary ? .bold : .medium)
        let tint:UIColor = style != .smallGray ? .link : (style == .smallGray ? .init(.greyText6) : .init(.white))
        titleLabel?.tintColor = tint
        titleLabel?.textColor = tint
        tintColor = tint
        if defaultConstraints {
            self.addConstaits(style == .primary ? [.height:53] : [.width:40, .height:40])
        }
    }
}
