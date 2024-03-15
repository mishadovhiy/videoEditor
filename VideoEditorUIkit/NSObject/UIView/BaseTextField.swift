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
            defaultTextFieldStyle()
        }
    }
    
    func defaultTextFieldStyle() {
        font = .type(.regular)
        textColor = .init(.white)
        placeholder = super.placeholder
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
