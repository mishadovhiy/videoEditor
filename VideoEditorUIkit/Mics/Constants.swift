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
        case secondaryBackground = "secondaryBackground"
        case black = "black"
        case separetor = "separetor"
        case white = "white"
        case greyText = "greyText"
        case greyText6 = "greyText6"
        case lightSeparetor = "lightSeparetor"
        case overlay = "overlay"
        case darkYellow = "#908C58"
        case yellow = "#F7B500"
        case yellow1 = "#FFB400"//"#FFAB00"
        case yellow2 = "#EAD291"
        case orange = "#FF8900"
        case orange2 = "#E9B08A"
        case darkOrange = "#FA6400"
        case green = "#6DD400"
        case greenBlue = "#44D7B6"
        case blue = "#32C5FF"
        case darkBlue = "#0091FF"
        case purpure = "#6236FF"
        case purpure2 = "7435C5"
        case pinkPurpure = "#B620E0"
        case lightPink = "#C371DA"
        case lightPink1 = "#F99FFF"
        case pinkRed = "#FF2071"
        case clear = "clear"
        case red2 = "#E02020"
        case pink2 = "#C353E2"
        case pink3 = "#CF73E9"
        
        static var trackColor:UIColor {
            return .init(hex: "1D1D1D") ?? .red
            //.type(.secondaryBackground)
        }
    }
    
    enum Font:CGFloat {
        case small = 10
        case smallMedium = 10.1
        case regular = 12
        case regulatMedium = 12.2
        case primaryButton = 14
        case secondaryButton = 12.1
        
        var font:UIFont {
            switch self {
            case .small, .smallMedium:
                return .systemFont(ofSize: rawValue, weight: self == .small ? .regular : .medium)
            case .regular, .regulatMedium:
                return .systemFont(ofSize: rawValue, weight: self == .regulatMedium ? .medium : .regular)
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
