//
//  TextAttachmentDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import UIKit

struct TextAttachmentDB:MovieAttachmentProtocol {
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
        inMovieStart = attachment.inMovieStart
        duration = attachment.duration
        assetName = attachment.assetName
        color = attachment.color
        defaultName = attachment.defaultName
        print(assetName, " rgetrfwedwfrg")
    }
    
    /// seconds
    var inMovieStart: CGFloat {
        get {
            .init(string: dict["inMovieStart"] as? String)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "inMovieStart")
        }
    }
    
    /// seconds
    var duration: CGFloat {
        get {
            .init(string: dict["duration"] as? String)
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "duration")
        }
    }
    
    var assetName: String? {
        get {
            dict["assetName"] as? String ?? ""
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
        get {
            dict["defaultName"] as? String ?? ""
        }
        set {
            dict.updateValue(newValue, forKey: "defaultName")
        }
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
            (dict["needScale"] as? Int ?? 0) == 1
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
            $0.inMovieStart = 1
            $0.assetName = "some text"
            $0.duration = 10
            $0.needScale = true
        })
    }
}

