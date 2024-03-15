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
    
    func calculate(inWindth:CGFloat? = nil, attributes:[NSAttributedString.Key: Any]? = nil, string:String, maxSize:CGSize? = nil) -> CGSize {
        let fontSize = self.pointSize
        let defaultWidth = UIApplication.shared.keyWindow?.frame.width ?? 100
        var textAttributes: [NSAttributedString.Key: Any] = [.font: fontSize]
        attributes?.forEach({
            textAttributes.updateValue($0.value, forKey: $0.key)
        })
        let attributedText = NSAttributedString(string: string, attributes: textAttributes)
        let boundingRect = attributedText.boundingRect(with: CGSize(width: inWindth ?? defaultWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
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
