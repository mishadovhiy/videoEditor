//
//  TextAttachmentDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import UIKit

struct TextAttachmentDB:MovieAttachmentProtocol, Equatable {
    var attachmentType: InstuctionAttachmentType? = .text
    static func == (lhs: TextAttachmentDB, rhs: TextAttachmentDB) -> Bool {
        return lhs.assetName == rhs.assetName
    }
    
    var dict:[String:Any]
    init(dict: [String : Any]) {
        self.dict = dict
    }
    
    init(attachment:MovieAttachmentProtocol?) {
        self.dict = [:]
        guard let attachment else {
            self = .demo
            return
        }
        self.attachmentType = .text
        inMovieStart = attachment.inMovieStart
        duration = attachment.duration
        assetName = attachment.assetName
        color = attachment.color
    }
    
    /// seconds
    var inMovieStart: CGFloat {
        get {
            let value = CGFloat.init(string: dict["inMovieStart"] as? String ?? "0.1")
            return value >= 1 ? 1 : (value <= 0 ? 0.1 : value)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "inMovieStart")
        }
    }
    
    /// seconds
    var duration: CGFloat {
        get {
            let value = CGFloat.init(string: dict["duration"] as? String ?? "0.5")
            return value >= 1 ? 1 : (value <= 0 ? 0.3 : value)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "duration")
        }
    }
    
    var assetName: String? {
        get {
            dict["assetName"] as? String ?? "-"
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
            return .init(hex: dict["color"] as? String ?? "") ?? .red
        }
        set {
            dict.updateValue(newValue.toHex, forKey: "color")
        }
    }
    
    var defaultName: String {
        return attachmentType?.rawValue ?? "-"
    }
    
    var id: UUID {
        .init()
    }
    
    var borderWidth:CGFloat {
        get {
            .init(string: dict["borderWidth"] as? String)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "borderWidth")
        }
    }
    
    var borderColor:UIColor {
        get {
            return .init(hex: dict["borderColor"] as? String ?? "") ?? .red
        }
        set {
            dict.updateValue(newValue.toHex, forKey: "borderColor")
        }
    }
    
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
    
    var needScale:Bool {
        get {
            (dict["needScale"] as? Int ?? 1) == 1
        }
        set {
            dict.updateValue(newValue ? 1 : 0, forKey: "needScale")
        }
    }
    
    var percentPositionY:CGFloat {
        get {
            .init(string: dict["percentPositionY"] as? String)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "percentPositionY")
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

extension TextAttachmentDB {
    static var demo:Self {
        return .with({
            $0.inMovieStart = 0.1
            $0.assetName = "New text"
            $0.duration = 0.4
            $0.needScale = true
        })
    }
}

extension [TextAttachmentDB] {
    static var demo:Self {
        let values = [(0.1, 0.3), (0.6, 0.3), (0.2, 0.2), (0.7, 0.08), (0.5, 0.3)]
        return values.compactMap { value in
            return .with {
                $0.inMovieStart = value.0
                $0.duration = value.1
                $0.assetName = ["some name", "other name"].randomElement() ?? "-"
            }
        }
    }
}

