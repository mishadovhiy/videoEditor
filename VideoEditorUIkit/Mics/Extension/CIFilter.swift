//
//  CIFilter.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 12.03.2024.
//

import CoreImage

extension CIFilter {
    convenience init?(type:FilterType) {
        self.init(name: type.rawValue)
    }
}

