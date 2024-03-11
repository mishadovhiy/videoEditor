//
//  MovieParameters.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

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

struct MovieGeneralParameterList {
    
    var songs:[SongRow]
    var text:[MovieAttachmentProtocol]
    var media:[MediaRow]
    var previewAssets:[AssetsData]
    /**
     - total duration of all assets
     */
    var duration:CGFloat {
        return previewAssets.reduce(0) { partialResult, data in
            return partialResult + data.duration
        }
    }
    
    var collectionWidth:CGFloat {
        previewAssets.reduce(0, { partialResult,data in
            return partialResult + data.sectionWidth
        })
    }
}


//MARK: Extensions
extension MovieGeneralParameterList.MediaRow {
    enum `Type`:String {
    case video, image
        static var random:Self {
            return [Self.video, Self.image].randomElement() ?? .image
        }
    }
    
}

extension MovieGeneralParameterList {
    struct PreviewData {
        var image:Data?
        init(_ image: Data? = nil) {
            self.image = image
        }
    }
}


