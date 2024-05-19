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
    
    var addingSpaceBeforeUppercase: String {
           var result = ""
           for character in self {
               if character.isUppercase {
                   // Add a space before the uppercase character unless it's the first character
                   if !result.isEmpty {
                       result.append(" ")
                   }
               }
               result.append(character)
           }
           return result
       }
}
