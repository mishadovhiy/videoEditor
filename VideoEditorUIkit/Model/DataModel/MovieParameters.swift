//
//  MovieParameters.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

struct MovieGeneralParameterList {
    
    var songs:[SongRow]
    var text:[RegularRow]
    var megia:[MediaRow]
    
    var asstes:[AssetsData]
    /**
     - total duration of all assets
     */
    var duration:CGFloat {
        return asstes.reduce(0) { partialResult, data in
            return partialResult + data.duration
        }
    }
}

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
            return "Attachment"
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

//MARK: test
extension MovieGeneralParameterList {
    static var test:Self {
        return .init(songs: .test, text: .test, megia: .test, asstes: .test)
    }
}

extension [MovieGeneralParameterList.AssetsData] {
    static var test:Self {
        let mins: [CGFloat] = [2.5, 1.15, 5.54]
        return mins.compactMap({
            return .init(duration: $0 * 60)
        })
    }
}

extension [MovieGeneralParameterList.RegularRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (2.40, 100)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration)
        })
    }
}

extension [MovieGeneralParameterList.MediaRow] {
    static var test:Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (20.40, 200.50)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration, type: .random)
        })
    }
}

extension [MovieGeneralParameterList.SongRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (50, 300.50)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration)
        })
    }
}

