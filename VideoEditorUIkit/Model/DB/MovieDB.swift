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
                return dict["originalURL"] as? String ?? ""
            }
            set {
                print("originalURLsettd ", newValue)
                dict.updateValue(newValue, forKey: "originalURL")
            }
        }
        
        var isOriginalUrl:Bool {
            get {
                let original = dict["isOriginalUrl"] as? Bool ?? false
                print("isoriginalurl: ", original)
                return original
            }
            set {
                dict.updateValue(newValue, forKey: "isOriginalUrl")
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
        
        var preview:Data? {
            get {
                return Data.init(base64Encoded: dict["preview"] as? String ?? "")
            }
            set {
                dict.updateValue(newValue?.base64EncodedString() ?? "", forKey: "preview")
            }
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

