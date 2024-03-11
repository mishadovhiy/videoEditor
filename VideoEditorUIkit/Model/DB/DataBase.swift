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
                let dict = dict["MovieParametersDB"] as? [String:Any] ?? [:]
                print(dict, " dataBase saving")
                return .init(dict: dict)
            }
            set {
                print(newValue.dict, " dataBase updated")
                dict.updateValue(newValue.dict, forKey: "MovieParametersDB")
            }
        }
    }
}
