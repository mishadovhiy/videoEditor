//
//  MovieSettingsDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 30.04.2024.
//

import Foundation

extension DB.DataBase {
    struct MovieSettingsDB {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var videoQuality:Constants.VideoQuality {
            get {
                if let dict = dict["videoQuality"] as? String
                {
                    return .init(rawValue: dict) ?? .default
                } else {
                    return Constants.VideoQuality.default
                }
            }
            set {
                dict.updateValue("\(newValue.rawValue)", forKey: "videoQuality")
            }
        }
        var videoSize:Constants.VideoQualitySizes {
            get {
                if let dict = dict["videoSize"] as? String,
                   let number = Int(dict)
                {
                    return .init(rawValue: number) ?? .default
                } else {
                    return Constants.VideoQualitySizes.default
                }
            }
            set {
                dict.updateValue("\(newValue.rawValue)", forKey: "videoSize")
            }
        }
        
        var defaultText:TextAttachmentDB {
            get {
                return .init(dict: dict["defaultText"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "defaultText")
            }
        }
        
        var defaultImage:ImageAttachmentDB {
            get {
                .init(dict: dict["defaultImage"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "defaultImage")
            }
        }
    }
}
