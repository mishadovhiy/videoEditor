//
//  UIImageView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.04.2024.
//

import UIKit

extension UIImageView {
    func setImage(_ named:String?, superView:UIView? = nil) {
        if let imageString = named,
           let imageRes = UIImage.init(named: imageString)
        {
            image = imageRes
            isHidden = false
            superView?.isHidden = false
        } else {
            isHidden = true
            superView?.isHidden = true
        }
    }
}
