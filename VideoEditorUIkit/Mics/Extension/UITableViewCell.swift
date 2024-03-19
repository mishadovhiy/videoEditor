//
//  UITableViewCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 19.03.2024.
//

import UIKit

extension UITableViewCell {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedColor(.clear)
    }
    
    func setSelectedColor(_ color:UIColor) {
        if self.selectedBackgroundView?.layer.name != "setSelectedColor" {
            let selected = UIView(frame: .zero)
            selected.layer.name = "setSelectedColor"
            selected.backgroundColor = color
            self.selectedBackgroundView = selected
        } else {
            self.selectedBackgroundView?.backgroundColor = color
        }
    }
}
