//
//  MessageContent.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation

struct MessageContent {
    var title:String? {
        didSet {
            userInfo?.updateValue(title, forKey: "title")
        }
    }
    var description = "" {
        didSet {
            userInfo?.updateValue(description, forKey: "description")
        }
    }
    var image: Constants.Images? = nil {
        didSet {
            userInfo?.updateValue(image?.rawValue ?? "", forKey: "image")
        }
    }
    
    var userInfo:[String : Any]? = nil
    
    init(title: String?, description: String? = nil, image: Constants.Images? = nil, userInfo: [String : Any]? = nil) {
        let resDescription = description ?? ""
        self.title = title != "" ? title : (userInfo?["title"] as? String ?? "")
        self.description = description != "" ? resDescription : (userInfo?["description"] as? String ?? "")
        self.image = image != nil ? image : .init(rawValue: userInfo?["image"] as? String ?? "")
        self.userInfo = userInfo
    }
}
