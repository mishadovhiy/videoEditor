//
//  DB_AnimationMovieAttachment.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 18.03.2024.
//

import Foundation

extension DB.DataBase.MovieParametersDB {
    struct AnimationMovieAttachment {
        
        var dict:[String:Any]
        
        var needScale:Bool {
            get {
                return (dict["needScale"] as? Int ?? 0) == 1
            }
            set {
                dict.updateValue(newValue ? 1 : 0, forKey: "needScale")
            }
        }
        
        var disapeareAnimation:AnimationData {
            get {
                return .init(dict: dict["disapeareAnimation"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "disapeareAnimation")
            }
        }
        
        var appeareAnimation:AnimationData {
            get {
                return .init(dict: dict["appeareAnimation"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "appeareAnimation")
            }
        }
        
        var repeatedAnimations:[AnimationData] {
            get {
                return (dict["repeatedAnimations"] as? [[String:Any]] ?? []).compactMap {
                    .init(dict: $0)
                }
            }
            set {
                dict.updateValue(newValue.compactMap({
                    $0.dict
                }), forKey: "repeatedAnimations")
            }
        }
        
        
        struct AnimationData {
            var dict:[String:Any] = [:]
            
            var key:AppeareAnimationType {
                get {
                    return .init(rawValue: dict["AppeareAnimationType"] as? String ?? "") ?? .opacity
                }
                set {
                    dict.updateValue(newValue.rawValue, forKey: "AppeareAnimationType")
                }
            }
            
            var duration:CGFloat {
                get {
                    if let value = dict["duration"] as? String {
                        return .init(string: dict["duration"] as? String)
                    } else {
                        return 0.8
                    }
                }
                set {
                    dict.updateValue(String.init(value: newValue), forKey: "duration")
                }
            }
            
            var value:CGFloat {
                get {
                    if let value = dict["value"] as? String {
                        return .init(string: dict["value"] as? String)
                    } else {
                        return 0.8
                    }
                }
                set {
                    dict.updateValue(String.init(value: newValue), forKey: "value")
                }
            }
            
            enum AppeareAnimationType:String {
                case opacity = "opacity"
                case scale = "transform.scale"
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
