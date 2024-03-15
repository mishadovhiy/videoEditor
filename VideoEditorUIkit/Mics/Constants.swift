//
//  K.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

struct Constants {
    enum Images:String {
        case cancel = "cancel"
    }
    enum Color:String {
        case primaryBackground = "primaryBackground"
        case black = "black"
        case separetor = "separetor"
        case white = "white"
        case greyText = "greyText"
        case greyText6 = "greyText6"
        case lightSeparetor = "lightSeparetor"
        
        static var trackColor:UIColor {
            return .white.withAlphaComponent(0.1)
        }
    }
    
    enum Font:CGFloat {
        case small = 10
        case smallMedium = 10.1
        case regular = 12
        case primaryButton = 16
        case secondaryButton = 12.1
        
        var font:UIFont {
            switch self {
            case .small, .smallMedium:
                return .systemFont(ofSize: rawValue, weight: self == .small ? .regular : .medium)
            case .regular:
                return .systemFont(ofSize: rawValue, weight: .regular)
            case .primaryButton, .secondaryButton:
                return .systemFont(ofSize: rawValue)
            }
        }
    }
}

extension Constants {
    struct Keys {
        enum Filter:String {
        case invert
        }
    }
}
