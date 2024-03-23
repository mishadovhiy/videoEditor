//
//  MovieParameters.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

struct MovieGeneralParameterList {
    
    var songs:[AssetAttachmentProtocol]
    var text:[MovieAttachmentProtocol]
    var media:[MovieAttachmentProtocol]
    var previewAssets:[AssetsData]
    /**
     - total duration of all assets
     */
    var duration:CGFloat {
        return previewAssets.reduce(0) { partialResult, data in
            return partialResult + data.time.duration
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
        var image:Data? = nil
        var time:Double? = nil
    }
}


