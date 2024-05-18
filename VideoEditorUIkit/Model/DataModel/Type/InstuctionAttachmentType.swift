//
//  InstuctionAttachmentType.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation

enum InstuctionAttachmentType:String, CaseIterable {
    
    case song, text, media
    
    var order:Int {
        switch self {
        case .song: return 1
        case .text: return 2
        case .media: return 3
        }
    }
    
    static func configure(_ n: Int) -> Self {
        Self.allCases.first(where: {
            $0.order == n
        }) ?? .song
    }
    
    var title:String {
        switch self {
        case .media: return "Image"
        case .song: return "Audio"
        default: return rawValue.capitalized
        }
    }
    
    var colorName:String {
        switch self {
        case .media: return "#B620E0"
        case .song: return "#6236FF"
        default: return "#F7B500"
        }
    }
}
