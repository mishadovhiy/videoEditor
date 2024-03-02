//
//  String.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import Foundation
import CoreGraphics

extension String {
    init(decimalCount:Int = 2, value:CGFloat) {
        self.init(format: "%.\(decimalCount)f", value)
    }
}
