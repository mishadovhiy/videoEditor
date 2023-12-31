//
//  DataBase.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import Foundation

extension DB {
    struct DataBase {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var movieParameters: MovieParametersDB {
            get {
                return .init(dict: dict["MovieParametersDB"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "MovieParametersDB")
            }
        }
    }
}
