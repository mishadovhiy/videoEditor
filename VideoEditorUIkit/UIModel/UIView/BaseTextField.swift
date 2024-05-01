//
//  BaseTextField.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 15.03.2024.
//

import UIKit

class BaseTextField:UITextField {
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                self.defaultTextFieldStyle()
            })
        }
    }
    
    override var placeholder: String? {
        get {
            return attributedPlaceholder?.string
        }
        set {
            attributedPlaceholder = .init(string: newValue ?? "", attributes: [
                .foregroundColor:(textColor ?? .type(.black)).withAlphaComponent(0.5)
            ])
        }
    }
    
    override var textColor: UIColor? {
        get {
            return super.textColor
        }
        set {
            super.textColor = newValue
            self.placeholder = super.placeholder
        }
    }
}

// MARK: - loadUI
fileprivate extension BaseTextField {
    func defaultTextFieldStyle() {
        font = .type(.regulatMedium)
        textColor = .init(.black)
    }
}
