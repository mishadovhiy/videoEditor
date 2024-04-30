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
        
        var videoQuality:String {
            get {
                dict["videoQuality"] as? String ?? Constants.videoQualities[Constants.defaultQualityIndex]
            }
            set {
                dict.updateValue(newValue, forKey: "videoQuality")
            }
        }
        var videoSize:CGSize {
            get {
                if let dict = dict["videoSize"] as? [String:Any] {
                    return .init(width: .init(string: dict["width"] as? String), height: .init(string: dict["height"] as? String))
                } else {
                    return Constants.videoQalitySizes[Constants.defaulQalitySizeIndex]
                }
            }
            set {
                dict.updateValue([
                    "width":String.init(value: newValue.width),
                    "height":String.init(value: newValue.height)
                ], forKey: "videoSize")
            }
        }
        
        var videoSizeQualityIndex:Int {
            var i = 0
            let size = videoSize
            var selectedAt:Int?
            Constants.videoQalitySizes.forEach {
                if size == $0 {
                    selectedAt = i
                }
                i += 1
            }
            return selectedAt ?? Constants.defaulQalitySizeIndex
        }
        
        var videoQualityIndex:Int {
            var i = 0
            let size = videoQuality
            var selectedAt:Int?
            Constants.videoQualities.forEach {
                if size == $0 {
                    selectedAt = i
                }
                i += 1
            }
            return selectedAt ?? Constants.defaultQualityIndex
        }
        
        var defaultText:TextAttachmentDB {
            get {
                .init(dict: dict["defaultText"] as? [String:Any] ?? [:])
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
