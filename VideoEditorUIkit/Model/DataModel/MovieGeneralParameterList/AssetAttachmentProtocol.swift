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
    /// percent in movie asset
    var duration:CGFloat {get set}
    var inMovieStart:CGFloat {get set}
    var assetName:String? {get set}
    var color:UIColor {get}
    var defaultName:String { get }
    var attachmentType:InstuctionAttachmentType? { get}
    var id:UUID { get }
}

protocol MovieAttachmentProtocol:AssetAttachmentProtocol {
    /// percent in movie asset
    var position:CGPoint {get set}
    var zoom:CGFloat { get set }
}

extension [AssetAttachmentProtocol] {
    func layerNumber(item:AssetAttachmentProtocol) -> Int? {
        var at:Int = 0
        self.forEach {
            let from = $0.inMovieStart * 100
            let to = ($0.duration * 100) + from
            let mainRange = from..<to
            let subRange = (item.inMovieStart * 100)..<((item.duration + item.inMovieStart) * 100)
            
            if mainRange.contains(subRange.lowerBound) || mainRange.contains(subRange.upperBound) || subRange.contains(mainRange.lowerBound) || subRange.contains(mainRange.upperBound) {
                at += 1
            } else if subRange.upperBound >= mainRange.lowerBound && subRange.upperBound <= mainRange.upperBound {
                at += 1
            }
        }
        print(at)
        if at >= 4 {
            return Int.random(in: 0..<3)
        }
        return at
    }
}


//MARK: List
extension MovieGeneralParameterList {
    struct AssetsData:AssetAttachmentProtocol {
        var id: UUID = .init()
        var inMovieStart: CGFloat = 0
        let attachmentType: InstuctionAttachmentType? = nil
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
        
        static func create(_ asset:AVAssetTrackSegment, composition:AVMutableComposition?, loadPreviews:Bool) -> AssetsData {
            let count = Int(asset.timeMapping.source.duration.seconds * (cellWidth / (2 * cellWidthMultiplier)))
            var array:[Int] = []
            for i in 0..<Int(count) {
                array.append(i)
            }
            if loadPreviews {
                return .init(duration: asset.timeMapping.source.duration.seconds, assetName: asset.description, previews: array.compactMap({
                    let plus = (CGFloat($0) / CGFloat(Int(count))) * asset.timeMapping.source.end.seconds
                    let previewTime:CMTime = .init(seconds: asset.timeMapping.source.start.seconds + plus, preferredTimescale: VideoEditorModel.timeScale)
                    return .init(composition?.preview(time: previewTime)?.jpegData(compressionQuality: 0.1))
                }))
            } else {
                return .init(duration: asset.timeMapping.source.duration.seconds, assetName: asset.description, previews: array.compactMap({_ in 
                    .init(nil)
                }))
            }
            
        }
    }
}


extension MovieGeneralParameterList {
    struct RegularRow:MovieAttachmentProtocol {
        var zoom:CGFloat = 1
        var position: CGPoint = .zero
        let attachmentType: InstuctionAttachmentType? = .text
        var inMovieStart: CGFloat
        var duration: CGFloat
        var assetName: String? = nil
        var id: UUID = .init()
        
        var color: UIColor {
            return .gray
        }
        
        var defaultName: String {
            return attachmentType?.rawValue.capitalized ?? "-"
        }
    }
    
    struct SongRow:AssetAttachmentProtocol {
        var id: UUID = .init()
        let attachmentType: InstuctionAttachmentType? = .song
        var inMovieStart: CGFloat
        var duration: CGFloat
        var assetName: String? = nil
        
        var color: UIColor {
            return .purple
        }
        
        var defaultName: String {
            return attachmentType?.rawValue.capitalized ?? "-"
        }

    }
    
    struct MediaRow:MovieAttachmentProtocol {
        var zoom:CGFloat = 1
        var position: CGPoint = .zero
        var attachmentType: InstuctionAttachmentType? {
            return .media
        }
        
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
