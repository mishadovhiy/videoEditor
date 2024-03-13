//
//  CALayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 14.03.2024.
//

import QuartzCore

extension CALayer {
    func cornerRadius(at position: RadiusPosition, value:CGFloat? = nil) {
        switch position {
        case .left:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .right:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        case .top:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    enum RadiusPosition {
        case left, right, top, bottom
    }
}
