//
//  CGFont.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 13.03.2024.
//

import UIKit

extension UIFont {
    static func type(_ font:Constants.Font) -> UIFont {
        return font.font
    }
    
    func calculate(inWindth:CGSize? = nil, attributes:[NSAttributedString.Key: Any]? = nil, string:String, maxSize:CGSize? = nil) -> CGSize {
        let defaultWidth = UIApplication.shared.keyWindow?.frame ?? .zero
        var textAttributes: [NSAttributedString.Key: Any] = [.font: self]
        attributes?.forEach({
            textAttributes.updateValue($0.value, forKey: $0.key)
        })
        let attributedText = NSAttributedString(string: string == "" ? "-" : string, attributes: textAttributes)
        print(attributedText, " gterfwdqswefrg")
        print(inWindth, " gerfwdq ", defaultWidth)
        let boundingRect = attributedText.boundingRect(with: inWindth ?? defaultWidth.size, options: .usesLineFragmentOrigin, context: nil)
        var size = CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))
        if let maxSize {
            if size.width >= maxSize.width {
                size.width = maxSize.width
            }
            if size.height >= maxSize.height {
                size.height = maxSize.height
            }
        }
        return size

    }
}
