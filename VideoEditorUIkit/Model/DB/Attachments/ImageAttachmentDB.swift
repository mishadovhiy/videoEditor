//
//  ImageAttachmentDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import UIKit

struct ImageAttachmentDB {
    
    var dict:[String:Any] = [:]
    var attachmentType: InstuctionAttachmentType? = .media
    var id: UUID = .init()
    private let defaultColor:UIColor = .type(.darkBlue)
    
    var image:Data? {
        get {
            return .init(base64Encoded: dict["image"] as? String ?? "")
        }
        set {
            guard let string = newValue?.base64EncodedString() else {
                dict.removeValue(forKey: "image")
                return
            }
            dict.updateValue(string, forKey: "image")
        }
    }
    
    var borderRadius:CGFloat {
        get {
            if let value = dict["borderRadius"] as? String {
                return .init(string: value)
            } else {
                return 0.5
            }
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "borderRadius")
        }
    }
    
    var backgroundColor: UIColor {
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
    
    var opacity:CGFloat {
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
}

// MARK: - MovieAttachmentProtocol
extension ImageAttachmentDB:MovieAttachmentProtocol {
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
            dict["assetName"] as? String ?? "Image"
           // return URL(string: attachme)
        }
        set {
            if let newValue {
                dict.updateValue(newValue, forKey: "assetName")
            } else {
                dict.removeValue(forKey: "assetName")
            }
        }
    }
    
    var trackColor: UIColor {
        return defaultColor
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
            .init(string: dict["zoom"] as? String ?? "0.4")
        }
        set {
            print(newValue, " tgerfwd")
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
extension ImageAttachmentDB:Equatable {
    static func == (lhs: ImageAttachmentDB, rhs: ImageAttachmentDB) -> Bool {
        return lhs.assetName == rhs.assetName &&
        lhs.position == rhs.position &&
        lhs.time == rhs.time &&
        lhs.color == rhs.color &&
        lhs.borderColor == rhs.borderColor &&
        lhs.borderWidth == rhs.borderWidth
    }
}

// MARK: - configure
extension ImageAttachmentDB {
    public static func with(
        _ populator: (inout Self) throws -> ()
    ) rethrows -> Self {
        var message = Self(dict: [:])
        try populator(&message)
        return message
    }
}
