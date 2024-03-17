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
                return (dict["needScale"] as? Int ?? 1) == 1
            }
            set {
                dict.updateValue(newValue ? 1 : 0, forKey: "needScale")
            }
        }
    }
}
