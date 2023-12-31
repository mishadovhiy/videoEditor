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
    }
    
    
}
