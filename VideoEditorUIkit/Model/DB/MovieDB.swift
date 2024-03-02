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
//            get {
//                return allMovieParameters.first(where: {$0.url == editingMovieURL})
//            }
//            set {
//                var all = allMovieParameters
//                if let first = all.first(where: {$0.url == newValue?.url}) {
//                    var results = first
//                    results.texts = newValue?.texts ?? []
//                    all.append(results)
//                } else if let newValue {
//                    all.append(newValue)
//                }
//                guard let _ = newValue else {
//                    dict.removeValue(forKey: "movies")
//                    return
//                }
//                dict.updateValue(all, forKey: "movies")
//            }
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
                
                return contents.last?.absoluteString
            } catch {
                print("Error: \(error)")
                return nil
            }
        }
        
        func clearTemporaryDirectory(exept:URL? = nil) {
            print("clearTemporaryDirectory isall: ", exept == nil)
            let fileManager = FileManager.default
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

            do {
                let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])

                try contents.forEach({
                    if $0 != exept || exept == nil {
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
        
        public static func with(
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(dict: [:])
            try populator(&message)
            return message
        }
    }
}

