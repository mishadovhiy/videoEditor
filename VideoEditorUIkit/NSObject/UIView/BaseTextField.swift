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
    
    func defaultTextFieldStyle() {
        font = .type(.regular)
        textColor = .init(.black)
        placeholder = super.placeholder
        backgroundColor = .type(.greyText6)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = UIColor.type(.greyText).cgColor
        layer.borderWidth = 0.5
    }
    
    override var placeholder: String? {
        get {
            return attributedPlaceholder?.string
        }
        set {
            attributedPlaceholder = .init(string: newValue ?? "", attributes: [
                .foregroundColor:UIColor.type(.greyText)
            ])
        }
    }
}
