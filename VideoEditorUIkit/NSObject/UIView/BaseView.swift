//
//  BaseView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class BaseView:UIView {
    @IBInspectable var cornderRadious:CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = self.cornderRadious
        }
    }
}
