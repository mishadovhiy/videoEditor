//
//  AssetAttachmentProtocol.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit
import AVFoundation

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
        
        static var cellWidth:CGFloat {
            return 10 * cellWidthMultiplier
        }
        fileprivate static let cellWidthMultiplier:CGFloat = 4
        var sectionWidth:CGFloat {
            return CGFloat(previews.count) * MovieGeneralParameterList.AssetsData.cellWidth
        }
        
        static func create(_ asset:AVCompositionTrackSegment, composition:AVMutableComposition?) -> AssetsData {
            let count = Int(asset.timeMapping.source.duration.seconds * (cellWidth / (2 * cellWidthMultiplier)))
            var array:[Int] = []
            for i in 0..<Int(count) {
                array.append(i)
            }
            return .init(duration: asset.timeMapping.source.duration.seconds, assetName: asset.description, previews: array.compactMap({
                let plus = (CGFloat($0) / CGFloat(Int(count))) * asset.timeMapping.source.end.seconds
                return .init(composition?.preview(time: .init(seconds: asset.timeMapping.source.start.seconds + plus, preferredTimescale: EditorModel.timeScale))?.pngData())
            }))
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
