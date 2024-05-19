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
            
            enum AppeareAnimationType:String, CaseIterable {
                case opacity = "opacity"
                case scale = "transform.scale"
                
                var index: Int {
                    var i = 0
                    var result = 0
                    Self.allCases.forEach {
                        if $0.rawValue == self.rawValue {
                            result = i
                        }
                        i += 1
                    }
                    return result
                }
                
                static func configure(_ index:Int) -> Self {
                    return Self.allCases.first(where: {$0.index == index}) ?? .opacity
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
                    default: return rawValue.capitalized
                    }
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
}

typealias AppeareAnimationType = DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType
