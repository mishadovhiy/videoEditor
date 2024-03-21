//
//  DB_AssetTime.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation

extension DB.DataBase.MovieParametersDB {
    struct AssetTime:Equatable {
        static func == (lhs: DB.DataBase.MovieParametersDB.AssetTime, rhs: DB.DataBase.MovieParametersDB.AssetTime) -> Bool {
            return lhs.start == rhs.start && lhs.duration == rhs.duration
        }
        
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        /// max: 1.0
        var start: CGFloat {
            get {
                let value = CGFloat.init(string: dict["inMovieStart"] as? String ?? "0")
                return value >= 1 ? 1 : (value <= 0 ? 0 : value)
            }
            set {
                dict.updateValue(String.init(value: newValue), forKey: "inMovieStart")
            }
        }
        
        /// max: 1.0
        var duration: CGFloat {
            get {
                let value = CGFloat.init(string: dict["duration"] as? String ?? "0.2")
                return value >= 1 ? 1 : (value <= 0 ? 0 : value)
            }
            set {
                dict.updateValue(String.init(value: newValue), forKey: "duration")
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
