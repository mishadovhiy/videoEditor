//
//  MovieParametersDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
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
            guard let contents = AppDelegate.shared?.fileManager?.contents else {
                print("contents: no data at the url")
                return nil
            }
            print(editingMovie?.originalURL, " originalUrlGet")
            if editingMovie?.isOriginalUrl ?? false {
                let original = contents.first(where: {
                    print($0.absoluteString, " stored file url")
                    return $0.absoluteString.contains(editingMovie?.originalURL ?? "")
                })?.absoluteString ??  contents.first?.absoluteString
                print(original, " editingMovieURL")
                return original
            } else {
                let result = contents.last(where: {
                    return !$0.absoluteString.contains(editingMovie?.notFilteredURL ?? "") && !$0.absoluteString.contains(editingMovie?.forceOriginalURL ?? "")
                })?.absoluteString
                print(result, " editingMovieURL")
                return result ?? contents.last?.absoluteString
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
