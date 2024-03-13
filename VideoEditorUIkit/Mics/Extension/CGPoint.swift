//
//  CGPoint.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 13.03.2024.
//

import Foundation

extension CGPoint {
    func validate(_ maxValue:Self, minValue:Self = .zero) -> Self {
        var position = self
        if position.y >= maxValue.y {
            position.y = maxValue.y
        }
        if position.y <= minValue.y {
            position.y = minValue.y
        }
        if position.x >= maxValue.x {
            position.x = maxValue.x
        }
        if position.x <= minValue.x {
            position.x = minValue.x
        }
        return position
    }
}
