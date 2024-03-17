//
//  DB_Shadows.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import UIKit

extension DB.DataBase.MovieParametersDB {
    struct Shadows {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var color:UIColor {
            get {
                return .init(hex: dict["color"] as? String ?? "") ?? .green
            }
            set {
                dict.updateValue(newValue.toHex, forKey: "color")
            }
        }
        
        var opasity:CGFloat {
            get {
                if let size = dict["opasity"] as? String {
                    return .init(string: size)
                } else {
                    return 0
                }
            }
            set {
                dict.updateValue(String.init(value: newValue), forKey: "opasity")
            }
        }
        
        var radius:CGFloat {
            get {
                if let size = dict["radius"] as? String {
                    return .init(string: size)
                } else {
                    return 2
                }
            }
            set {
                dict.updateValue(String.init(value: newValue), forKey: "radius")
            }
        }
        
        public static func with(
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(dict: [:])
            try populator(&message)
            return message
        }
    }
}
