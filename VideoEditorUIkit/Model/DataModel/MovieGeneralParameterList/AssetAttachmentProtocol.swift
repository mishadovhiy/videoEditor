//
//  AssetAttachmentProtocol.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

//MARK: Protocol
protocol AssetAttachmentProtocol {
    var duration:CGFloat {get set}
    var assetName:String? {get set}
    var color:UIColor {get}
    var defaultName:String { get }
}

protocol MovieAttachmentProtocol:AssetAttachmentProtocol {
    var inMovieStart:CGFloat {get set}
    var id:UUID { get }
}

extension [MovieAttachmentProtocol] {
    func layerNumber(item:MovieAttachmentProtocol) -> Int {
        var at:Int = 0
        self.forEach {
            let mainRange = $0.inMovieStart..<($0.duration + $0.inMovieStart)
            let subRange = item.inMovieStart..<(item.duration + item.inMovieStart)
            
            if mainRange.contains(subRange.lowerBound) && mainRange.contains(subRange.upperBound) {
                at += 1
            }
        }
        print(at, " tregrfwed")
        return at
    }
}


//MARK: List
extension MovieGeneralParameterList {
    struct AssetsData:AssetAttachmentProtocol {
        
        var duration: CGFloat
        var assetName: String? = nil
        var previews:[PreviewData] = []
        
        var color: UIColor {
            return .white
        }

        var defaultName: String {
            return "Movie"
        }
    }
}


extension MovieGeneralParameterList {
    struct RegularRow:MovieAttachmentProtocol {
        
        var inMovieStart: CGFloat
        var duration: CGFloat
        var assetName: String? = nil
        var id: UUID = .init()
        
        var color: UIColor {
            return .gray
        }
        
        var defaultName: String {
            return "Text"
        }
    }
    
    struct SongRow:MovieAttachmentProtocol {
        
        var inMovieStart: CGFloat
        var duration: CGFloat
        var assetName: String? = nil
        var id: UUID = .init()
        
        var color: UIColor {
            return .purple
        }
        
        var defaultName: String {
            return "Song"
        }

    }
    
    struct MediaRow:MovieAttachmentProtocol {
        
        var inMovieStart: CGFloat
        var duration: CGFloat
        var assetName: String? = nil
        var type:Type = .image
        var previews:[PreviewData] = []
        var id: UUID = .init()
        
        var color: UIColor {
            switch type {
            case .video:
                return .red
            case .image:
                return .green
            }
        }
        
        var defaultName: String {
            switch type {
            case .video:
                return "Video"
            case .image:
                return "Image"
            }
        }
    }
}
