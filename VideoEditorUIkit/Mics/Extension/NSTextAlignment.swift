//
//  NSAlighmentTextLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import UIKit

extension NSTextAlignment {
    var textLayerAligmentMode:CATextLayerAlignmentMode {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        default: return .center
        }
    }
}
