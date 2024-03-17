//
//  InstuctionAttachmentType.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation

enum InstuctionAttachmentType:String {
    
    case song, text, media
    
    var order:Int {
        switch self {
        case .song: return 1
        case .text: return 2
        case .media: return 3
        }
    }
    
    var title:String {
        if self == .media {
            return "Image"
        }
        return rawValue.capitalized
    }
}
