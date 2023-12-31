//
//  DB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import Foundation

struct DB {
    static var holder: DataBase?
    static var db:DataBase {
        get {
            return holder ?? .init(dict: (UserDefaults.standard.value(forKey: "DataBase") as? [String:Any] ?? [:]))
        }
        set {
            holder = newValue
            if Thread.isMainThread {
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    UserDefaults.standard.setValue(newValue.dict, forKey: "DataBase")
                }
            } else {
                UserDefaults.standard.setValue(newValue.dict, forKey: "DataBase")
            }
        }
    }
}

