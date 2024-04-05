//
//  UIGestureRecognizer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.04.2024.
//

import UIKit

extension UIGestureRecognizer.State {
    var isEnded:Bool {
        switch self {
        case .ended, .cancelled, .failed:
            return true
        default: return false
        }
    }
}
