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
        setupUI()
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
        if cornderRadious == 0 {
            layer.cornerRadius = style == .primary ? 9 : 5
        }
        backgroundColor = style == .smallGray ? .lightGray : .link
        titleLabel?.font = .systemFont(ofSize: style == .primary ? 16 : 12, weight: style == .primary ? .bold : .medium)
        titleLabel?.tintColor = style == .smallGray ? .link : .white
        if defaultConstraints {
            self.addConstaits(style == .primary ? [.height:53] : [.width:40, .height:40])
        }
    }
}
