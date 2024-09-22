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
        
        var repeatedAnimations:AnimationData? {
            get {
                if let dict = dict["repeatedAnimations"] as? [String:Any] {
                    return .init(dict: dict)
                } else {
                    return nil
                }
            }
            set {
                if let newValue {
                    dict.updateValue(newValue.dict, forKey: "repeatedAnimations")
                } else {
                    dict.removeValue(forKey: "repeatedAnimations")
                }
            }
        }
        
        
        struct AnimationData {
            var dict:[String:Any] = [:]
            
            var key:AppeareAnimationType {
                get {
                    return .configure(dict["AppeareAnimationType"] as? String ?? "")
                }
                set {
                    dict.updateValue(newValue.stringValue, forKey: "AppeareAnimationType")
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
            
            var valueFloat:CGFloat {
                get {
                    if let value = dict["value"] as? String {
                        return .init(string: value)
                    } else {
                        return 0.8
                    }
                }
                set {
                    dict.updateValue(String.init(value: newValue), forKey: "value")
                }
            }
            
            enum AppeareAnimationType:Int, CaseIterable {
                case scale
                case opacity
                //case hidden
                
                var stringValue:String {
                    return switch self {
                    case .scale:"transform.scale"
                    case .opacity: "opacity"
                        //   case .hidden:"hidden"
                    }
                }
                
                static var repeatedTypes:[Self] {
                    let igonre:[Self] = [.opacity]
                    return allCases.filter({
                        !igonre.contains($0)
                    })
                }
                
                static func configure(_ string:String) -> Self {
                    return Self.allCases.first(where: {$0.stringValue == string}) ?? .opacity
                }
                
                var resultType:ResultType {
                    switch self {
                    default: .float
                    }
                }
                enum ResultType {
                    case float
                }
                var title:String {
                    switch self {
                    case .scale: return "Scale"
                    default: return stringValue.capitalized
                    }
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
                
        public static func with(
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(dict: [:])
            try populator(&message)
            return message
        }
    }
}

typealias AppeareAnimationType = DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType
