//
//  MovieParametersDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import Foundation

extension DB.DataBase {
    struct MovieParametersDB {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var needReloadLayerAttachments:Bool {
            get {
                return dict["needReloadText"] as? Bool ?? false
            }
            set {
                dict.updateValue(newValue, forKey: "needReloadText")
            }
        }
        
        var needReloadFilter:Bool {
            get {
                return dict["needReloadFilter"] as? Bool ?? false
            }
            set {
                dict.updateValue(newValue, forKey: "needReloadFilter")
            }
        }
        
        var editingMovie:MovieDB? {
            get {
                return .init(dict: dict["movies"] as? [String:Any] ?? [:])
            }
            set {
                if let newValue {
                    dict.updateValue(newValue.dict, forKey: "movies")
                } else {
                    dict.removeValue(forKey: "movies")
                }
            }
        }
        
        private var allMovieParameters:[MovieDB] {
            let parametersDict = dict["movies"] as? [String:Any] ?? [:]
            return parametersDict.compactMap {
                return .init(dict: $0.value as? [String:Any] ?? [:])
            }
        }
        
        var editingMovieURL:String? {
            let fileManager = FileManager.default
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            
            do {
                let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
                print(editingMovie?.originalURL, " originalUrlGet")
                if editingMovie?.isOriginalUrl ?? false {
                    let original = contents.first(where: {
                        print($0.absoluteString, " stored file url")
                        return $0.absoluteString.contains(editingMovie?.originalURL ?? "")
                    })?.absoluteString ??  contents.first?.absoluteString
                    print(original, " editingMovieURL")
                    return original
                } else {
                    let result = contents.last(where: {!$0.absoluteString.contains(editingMovie?.originalURL ?? "")})?.absoluteString
                    print(result, " editingMovieURL")
                    return result
                }
                
            } catch {
                print("Error: \(error)")
                return nil
            }
        }
        
        func clearTemporaryDirectory(exept:URL? = nil, urls:[String]? = nil) {
            print("clearTemporaryDirectory isall: ", exept == nil)
            let fileManager = FileManager.default
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            
            do {
                let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
                let originalUrl = editingMovie?.originalURL ?? ""
                let editingUrl = self.editingMovieURL ?? ""
                try contents.forEach({
                    let cantRemove = $0.absoluteString.contains(originalUrl) || $0 == exept || ($0.absoluteString.contains(editingUrl) && exept != nil)
                    if exept == nil || !cantRemove {
                        try fileManager.removeItem(at: $0)
                        print("Removed: \($0.lastPathComponent)")
                    }
                })
            } catch {
                print("Error: \(error)")
            }
        }
        
        var movies:[MovieDB] {
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
        
        public static func with(
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(dict: [:])
            try populator(&message)
            return message
        }
    }
}


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

