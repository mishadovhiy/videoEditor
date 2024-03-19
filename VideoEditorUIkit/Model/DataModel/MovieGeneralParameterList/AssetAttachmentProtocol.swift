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
    var time:DB.DataBase.MovieParametersDB.AssetTime { get set }
    var assetName:String? { get set }
    var defaultName:String { get }
    var attachmentType:InstuctionAttachmentType? { get }
    var color:UIColor { get }
    var trackColor:UIColor { get }
    var id:UUID { get }
}

protocol MovieAttachmentProtocol:AssetAttachmentProtocol {
    /// percent in movie asset
    var position:CGPoint { get set }
    var zoom:CGFloat { get set }
    var shadows:DB.DataBase.MovieParametersDB.Shadows { get set }
    var animations:DB.DataBase.MovieParametersDB.AnimationMovieAttachment { get set }
}

extension [AssetAttachmentProtocol] {
    func layerNumber(item:AssetAttachmentProtocol) -> Int? {
        var at:Int = 0
        self.forEach {
            let from = $0.time.start * 100
            let to = ($0.time.duration * 100) + from
            let mainRange = from..<to
            let subRange = (item.time.start * 100)..<((item.time.duration + item.time.start) * 100)
            
            if mainRange.contains(subRange.lowerBound) || mainRange.contains(subRange.upperBound) || subRange.contains(mainRange.lowerBound) || subRange.contains(mainRange.upperBound) {
                at += 1
            } else if subRange.upperBound >= mainRange.lowerBound && subRange.upperBound <= mainRange.upperBound {
                at += 1
            }
        }
        print(at)
        let song = (item as? SongAttachmentDB)
        if (song?.attachmentType ?? .media) == .song {
            if song?.selfMovie ?? false {
                return 1
            } else {
                return 0
            }
        }
        if at >= 4 {
            return Int.random(in: 0..<4)
        }
        return at
    }
}


//MARK: List
extension MovieGeneralParameterList {
    struct AssetsData:AssetAttachmentProtocol {
        var trackColor: UIColor {
            return color
        }
        
        
        var id: UUID = .init()
        var time:DB.DataBase.MovieParametersDB.AssetTime = .init(dict: [:])
        let attachmentType: InstuctionAttachmentType?
        var assetName: String? = nil
        var previews:[PreviewData] = []
        fileprivate static let cellWidthMultiplier:CGFloat = 4
        
        var color: UIColor {
            return .white
        }
        
        var defaultName: String {
            return "Movie"
        }
        
        static var cellWidth:CGFloat {
            return 10 * cellWidthMultiplier
        }
        
        var sectionWidth:CGFloat {
            return CGFloat(previews.count) * MovieGeneralParameterList.AssetsData.cellWidth
        }
        
        public static func with(type:InstuctionAttachmentType,
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(attachmentType: type)
            try populator(&message)
            return message
        }
        
        static func create(_ asset:AVAssetTrackSegment, composition:AVMutableComposition?, loadPreviews:Bool) -> AssetsData {
            let count = Int(asset.timeMapping.source.duration.seconds * (cellWidth / (2 * cellWidthMultiplier)))
            var array:[Int] = []
            for i in 0..<Int(count) {
                array.append(i)
            }
            if loadPreviews {
                return .init(time:.with({
                    $0.duration = asset.timeMapping.source.duration.seconds
                }), attachmentType: nil, assetName: asset.description, previews: array.compactMap({
                    let plus = (CGFloat($0) / CGFloat(Int(count))) * asset.timeMapping.source.end.seconds
                    let previewTime:CMTime = .init(seconds: asset.timeMapping.source.start.seconds + plus, preferredTimescale: VideoEditorModel.timeScale)
                    return .init(composition?.preview(time: previewTime)?.jpegData(compressionQuality: 0.1))
                }))
            } else {
                return .init(time: .with({
                    $0.duration = asset.timeMapping.source.duration.seconds
                }), attachmentType: nil, assetName: asset.description, previews: array.compactMap({_ in
                    .init(nil)
                }))
            }
        }
    }
}


extension MovieGeneralParameterList {
    struct RegularRow:MovieAttachmentProtocol {
        var trackColor: UIColor {
            return color
        }
        var animations: DB.DataBase.MovieParametersDB.AnimationMovieAttachment = .init(dict: [:])
        var shadows: DB.DataBase.MovieParametersDB.Shadows = .init(dict: [:])
        var zoom:CGFloat = 1
        var position: CGPoint = .zero
        let attachmentType: InstuctionAttachmentType?
        var time:DB.DataBase.MovieParametersDB.AssetTime = .init(dict: [:])
        var assetName: String? = nil
        var id: UUID = .init()
        
        var color: UIColor {
            return .gray
        }
        
        var defaultName: String {
            return attachmentType?.rawValue.capitalized ?? "-"
        }
        
        public static func with(type:InstuctionAttachmentType,
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(attachmentType: type)
            try populator(&message)
            return message
        }
    }
    
    struct SongRow:AssetAttachmentProtocol {
        var id: UUID = .init()
        var trackColor: UIColor {
            return color
        }
        let attachmentType: InstuctionAttachmentType? = .song
        var time:DB.DataBase.MovieParametersDB.AssetTime = .init(dict: [:])
        var assetName: String? = nil
        /// Track color
        var color: UIColor {
            return .purple
        }
        
        var defaultName: String {
            return attachmentType?.rawValue.capitalized ?? "-"
        }
        
        public static func with(
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self()
            try populator(&message)
            return message
        }
    }
    
    struct MediaRow:MovieAttachmentProtocol {
        var trackColor: UIColor {
            return color
        }
        var volume: CGFloat = 0
        var animations: DB.DataBase.MovieParametersDB.AnimationMovieAttachment = .init(dict: [:])
        var shadows: DB.DataBase.MovieParametersDB.Shadows = .init(dict: [:])
        var zoom:CGFloat = 1
        var position: CGPoint = .zero
        var time:DB.DataBase.MovieParametersDB.AssetTime = .init(dict: [:])
        var assetName: String? = nil
        var type:Type = .image
        var previews:[PreviewData] = []
        var id: UUID = .init()
        
        var attachmentType: InstuctionAttachmentType? {
            return .media
        }
        
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
        
        public static func with(
            _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self()
            try populator(&message)
            return message
        }
    }
}
