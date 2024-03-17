//
//  NSError.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation

extension NSError {
    convenience init(text:String?, userInfo:[String : Any]? = nil) {
        self.init(domain: text ?? "Unrecognized error",
                                  code: Int("") ?? 0,
                                  userInfo: userInfo)
    }
    
    var messageContent:MessageContent? {
        return .init(title: domain, userInfo: self.userInfo)
    }
}
