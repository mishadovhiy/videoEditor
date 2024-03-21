//
//  TextAttachmentDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import UIKit

struct TextAttachmentDB {
    
    var dict:[String:Any] = [:]
    var attachmentType: InstuctionAttachmentType? = .text
    var id: UUID = .init()
    private let defaultColor:UIColor = .type(.yellow)
    
    var fontSize:CGFloat {
        get {
            if let size = dict["fontSize"] as? String {
                return .init(string: size)
            } else {
                return 50
            }
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "fontSize")
        }
    }
    
    var fontWeight:UIFont.Weight {
        get {
            if let weight = dict["fontWeight"] as? String {
                return .init(.init(string: weight))
            } else {
                return UIFont.Weight.bold
            }
        }
        set {
            dict.updateValue(String(value:newValue.rawValue), forKey: "fontWeight")
        }
    }
    
    var textAlighment:NSTextAlignment {
        get {
            return .init(rawValue: dict["textAlighment"] as? Int ?? 1) ?? .center
        }
        set {
            dict.updateValue(newValue.rawValue, forKey: "textAlighment")
        }
    }
}

// MARK: - MovieAttachmentProtocol
extension TextAttachmentDB:MovieAttachmentProtocol {
    var opacity: CGFloat {
        get {
            if let value = dict["opacity"] as? String {
                return .init(string: value)
            } else {
                return 1
            }
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "opacity")
        }
    }
    
    var borderRadius: CGFloat {
        get {
            .init(string: dict["borderRadius"] as? String)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "borderRadius")
        }
    }
    
    var trackColor: UIColor {
        return color
    }
    
    var animations: DB.DataBase.MovieParametersDB.AnimationMovieAttachment {
        get {
            return .init(dict: dict["animations"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "animations")
        }
    }
    
    var defaultName: String {
        attachmentType?.rawValue ?? "?"
    }
    
    var time: DB.DataBase.MovieParametersDB.AssetTime {
        get {
            return .init(dict: dict["time"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "time")
        }
    }
    
    var assetName: String? {
        get {
            dict["assetName"] as? String ?? TextAttachmentDB.demo.assetName
        }
        set {
            if let newValue {
                dict.updateValue(newValue, forKey: "assetName")
            } else {
                dict.removeValue(forKey: "assetName")
            }
        }
    }
    
    var color: UIColor {
        get {
            if let value = dict["color"] as? String {
                return .init(hex: value) ?? defaultColor
            } else {
                return defaultColor
            }
        }
        set {
            if newValue != .clear, let toHex = newValue.toHex {
                dict.updateValue(toHex, forKey: "color")
            } else {
                dict.removeValue(forKey: "color")
            }
        }
    }
    
    var borderWidth:CGFloat {
        get {
            .init(string: dict["borderWidth"] as? String)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "borderWidth")
        }
    }
    
    var zoom:CGFloat {
        get {
            .init(string: dict["zoom"] as? String ?? "1")
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "zoom")
        }
    }
    
    var borderColor:UIColor {
        get {
            return .init(hex: dict["borderColor"] as? String ?? "") ?? .clear
        }
        set {
            if newValue != .clear, let toHex = newValue.toHex {
                dict.updateValue(toHex, forKey: "borderColor")
            } else {
                dict.removeValue(forKey: "borderColor")
            }        }
    }
    
    var backgroundColor:UIColor {
        get {
            return .init(hex: dict["backgroundColor"] as? String ?? "") ?? .clear
        }
        set {
            if newValue != .clear, let toHex = newValue.toHex {
                dict.updateValue(toHex, forKey: "backgroundColor")
            } else {
                dict.removeValue(forKey: "backgroundColor")
            }
        }
    }
    
    var shadows: DB.DataBase.MovieParametersDB.Shadows {
        get {
            return .init(dict: dict["shadow"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "shadow")
        }
    }
    
    var position:CGPoint {
        get {
            let dict = dict["position"] as? [String:Any] ?? [:]
            let y:CGFloat = .init(string: dict["y"] as? String)
            return .init(x: .init(string: dict["x"] as? String), y: y == 0 ? 200 : y)
        }
        set {
            dict.updateValue([
                "x":String.init(value: newValue.x),
                "y":String.init(value: newValue.y)
            ], forKey: "position")
        }
    }
}

// MARK: - Equatable
extension TextAttachmentDB:Equatable {
    static func == (lhs: TextAttachmentDB, rhs: TextAttachmentDB) -> Bool {
        return lhs.assetName == rhs.assetName &&
        lhs.position == rhs.position &&
        lhs.time == rhs.time &&
        lhs.color == rhs.color &&
        lhs.borderColor == rhs.borderColor &&
        lhs.borderWidth == rhs.borderWidth
    }
}

// MARK: - Array
extension [TextAttachmentDB] {
    static var demo:Self {
        let values = [(0.1, 0.3), (0.6, 0.3), (0.2, 0.2), (0.7, 0.08), (0.5, 0.3)]
        return values.compactMap { value in
            return .with {
                $0.time.start = value.0
                $0.time.duration = value.1
                $0.assetName = ["some name", "other name"].randomElement() ?? "-"
            }
        }
    }
}

// MARK: configure
extension TextAttachmentDB {
    static var demo:Self {
        return .with({
            $0.time.start = 0.1
            $0.assetName = "New text"
            $0.time.duration = 0.2
            $0.animations.needScale = true
            $0.attachmentType = .text
        })
    }
    
    public static func with(
        _ populator: (inout Self) throws -> ()
    ) rethrows -> Self {
        var message = Self(dict: [:])
        try populator(&message)
        return message
    }
}
