//
//  CGFloat.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import Foundation

extension CGFloat {
    init(string:String?) {
        if let string,
           let number = NumberFormatter().number(from: string) {
            self.init(truncating: number)
        } else if let string, string != "" {
            self.init(Double(string) ?? 0)
        } else {
            self = 0
        }
    }
}
