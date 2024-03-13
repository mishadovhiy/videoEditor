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
        
        static var trackColor:UIColor {
            return .white.withAlphaComponent(0.1)
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
