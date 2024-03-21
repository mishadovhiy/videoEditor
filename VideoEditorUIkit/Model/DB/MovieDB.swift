//
//  MovieParametersDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import Foundation

extension DB.DataBase.MovieParametersDB {
    struct MovieDB {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var url:String {
            get {
                return dict["url"] as? String ?? ""
            }
            set {
                dict.updateValue(newValue, forKey: "url")
            }
        }
        
        var originalURL:String {
            get {
                return filtered ? notFilteredURL : forceOriginalURL
            }
            set {
                print("originalURLsettd ", newValue)
                if forceOriginalURL != newValue {
                    lastChangedURL = forceOriginalURL
                }
                if filtered {
                    notFilteredURL = newValue
                } else {
                    forceOriginalURL = newValue
                }
            }
        }
        
        var forceOriginalURL:String {
            get {
                return dict["originalURL"] as? String ?? ""
            }
            set {
                print("originalURLsettd ", newValue)
                dict.updateValue(newValue, forKey: "originalURL")
            }
        }
        
        var notFilteredURL:String {
            get {
                return dict["notFilteredURL"] as? String ?? ""
            }
            set {
                print("originalURLsettd ", newValue)
                dict.updateValue(newValue, forKey: "notFilteredURL")
            }
        }
        
        mutating func setPreviusVideoURL() {
            forceOriginalURL = lastChangedURL
            isOriginalUrl = true
        }
        
        var isOriginalUrl:Bool {
            get {
                let original = dict["isOriginalUrl"] as? Bool ?? true
                print("isoriginalurl: ", original)
                return original
            }
            set {
                dict.updateValue(newValue, forKey: "isOriginalUrl")
            }
        }
        
        var lastChangedURL:String {
            get {
                return dict["notFilteredURL"] as? String ?? ""
            }
            set {
                print("originalURLsettd ", newValue)
                dict.updateValue(newValue, forKey: "notFilteredURL")
            }
        }
        
        var compositionURLs:[String] {
            get {
                return dict["compositionURLs"] as? [String] ?? []
            }
            set {
                dict.updateValue(newValue, forKey: "compositionURLs")
            }
        }
        
        var texts:[TextAttachmentDB] {
            get {
                let dicts = dict["MovieDB"] as? [[String:Any]]
                return dicts?.compactMap({
                    return .init(dict: $0)
                }) ?? []
            }
            set {
                dict.updateValue(newValue.compactMap({$0.dict}), forKey: "MovieDB")
            }
        }
        
        var songs:SongAttachmentDB {
            get {
                .init(dict: dict["songs"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "songs")
            }
        }
        
        var images:[ImageAttachmentDB] {
            get {
                let dicts = dict["images"] as? [[String:Any]]
                return dicts?.compactMap({
                    return .init(dict: $0)
                }) ?? []
            }
            set {
                dict.updateValue(newValue.compactMap({$0.dict}), forKey: "images")
            }
        }
        
        var videoEdited:Bool {
            if images.count != 0 || texts.count != 0 || songs.attachmentURL != "" {
                return true
            }
            print("videoNotEdited")
            return false
        }
        
        /// max: 1.0
        var valume: CGFloat {
            get {
                if let _ = Double(dict["valume"] as? String ?? "") {
                    let value = CGFloat.init(string: dict["valume"] as? String ?? "1")
                    return value >= 1 ? 1 : (value <= 0 ? 0 : value)
                } else {
                    return 1
                }
            }
            set {
                dict.updateValue(String.init(value: newValue), forKey: "valume")
            }
        }
        
        var preview:Data? {
            get {
                return Data.init(base64Encoded: dict["preview"] as? String ?? "")
            }
            set {
                dict.updateValue(newValue?.base64EncodedString() ?? "", forKey: "preview")
            }
        }
        
        var filtered:Bool {
            return filter != .none
        }
        
        var filter:FilterType {
            get {
                return .init(rawValue: dict["filter"] as? String ?? "") ?? .none
            }
            set {
                dict.updateValue(newValue.rawValue, forKey: "filter")
            }
        }
        
        
        mutating func removeEditedAsset(_ attachment:AssetAttachmentProtocol?) {
            if let text = attachment as? TextAttachmentDB {
                var removed = false
                texts.removeAll(where: {
                    if !removed {
                        removed = true
                        return text == $0
                    } else {
                        return false
                    }
                })
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

