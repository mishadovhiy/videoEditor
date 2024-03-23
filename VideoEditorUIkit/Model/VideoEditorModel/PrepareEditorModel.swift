//
//  EditorLayerModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

class PrepareEditorModel {
    
    private var delegate:PrepareEditorModelDelegate!
    private let layerEditor:EditorVideoLayer
    var videoCompositionHolder:AVMutableVideoComposition?
    
    init(delegate: PrepareEditorModelDelegate) {
        self.delegate = delegate
        self.layerEditor = .init()
    }
    
    deinit {
        delegate = nil
    }
    
    @MainActor func export(asset:AVAsset?, videoComposition:AVMutableVideoComposition?, isVideo:Bool = false, isQuery:Bool = false, voluem:Float? = nil) async -> Response {
        print(asset?.duration, " export duration")
        guard let composition = delegate.movieHolder ?? delegate.movie
        else {
            print("error movieHolder and no delegate.movie", #file, #line, #function)
            return .error(.init(title:"Error exporting the video", description: "Try reloading the app"))
        }
        let export = AVAssetExportSession(asset: composition, presetName: VideoEditorModel.exportPresetName)
        let results = await export?.exportVideo(videoComposition: videoComposition, isVideoAdded: isVideo, volume: voluem ?? 1 == 1 ? nil : voluem)
        if let url = results?.videoExportResponse?.url?.lastPathComponent {
            DB.db.movieParameters.editingMovie?.exportEditingURL = url
        }
        return results ?? .error("Unknown Error")
    }
    
    func addAttachments() async -> Response {
        let asset = delegate.movie ?? .init()
        print(asset.duration, " video duration")
        guard let composition = delegate.movieHolder
        else {
            return .error("Error adding text to the video")
        }
        let assetTrack = asset.tracks(withMediaType: .video)
        guard let firstTrack = assetTrack.first(where: {$0.naturalSize.width != 0}) else {
            return .error("Video frames are to small")
        }
        let videoSize = layerEditor.videoSize(assetTrack: firstTrack)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        let videoComposition = await allCombinedInstructions(composition: composition, assetTrack: assetTrack, videoSize: videoSize, overlayLayer: overlayLayer)
        delegate.movieHolder = composition
        let localUrl = await export(asset: composition, videoComposition: videoComposition, isVideo: false)
        if let url = localUrl.videoExportResponse?.url {
            DB.db.movieParameters.editingMovie?.notFilteredURL = url.lastPathComponent
            self.videoCompositionHolder = videoComposition
            await self.movieUpdated(movie: nil, movieURL: url, canSetNil: false)
        }
        return localUrl
    }

    func createVideo(_ url:URL?, needExport:Bool = true, setGeneralAudio:Bool = false, addingVideo:Bool = false) async -> Response {
        let movie = delegate.movie ?? .init()
        guard let url else {
            return .error("File not found")
        }
        let newMovie = await createComposition(AVURLAsset(url: url))
        let createdMovieResponse = await insertMovie(movie: newMovie.composition, composition: movie)
        if let error = createdMovieResponse.error {
            return .init(error: error)
        }
        delegate.movieHolder = createdMovieResponse.resultMovie
        if needExport {
            let localUrl = await export(asset: movie, videoComposition: nil, isVideo: true)
            if let url = localUrl.videoExportResponse?.url {
                if addingVideo {
                    DB.db.movieParameters.editingMovie?.originalURL = url.lastPathComponent
                }
                await self.movieUpdated(movie: movie, movieURL: localUrl.videoExportResponse?.url ?? delegate.movieURL)
            }
            return localUrl
        } else {
            return .success()
        }
    }
    
    func addFilter(completion:@escaping()->()) async {
        let movie = delegate.movieHolder ?? delegate.movie!
        let video = VideoFilter.addFilter(composition: movie, completion: { url in
            Task {
                if await self.filterAddedToComposition(url, videoComposition: self.videoCompositionHolder) {
                    
                }
                completion()
            }
        })
        
        let localUrl = await export(asset: movie, videoComposition: video.composition, isVideo: false)
        
        if let url = localUrl.videoExportResponse?.url {
            await self.movieUpdated(movie: movie, movieURL: url, canSetNil: false)
        }
    }
}


extension PrepareEditorModel {
    typealias insertMovieResponse = (resultMovie:AVMutableComposition?, error:NSError?)
    
    private func insertMovie(movie:AVMutableComposition?, composition:AVMutableComposition) async -> insertMovieResponse {
        guard let movie
        else {
            return (nil, .init(text: "Video not found"))
        }
        let duration = await movie.duration()
        if duration == .zero {
            return (nil, .init(text: "Video is empty"))
        }
        print(duration, " total coposition duration before inserting")
        let currentMovieSize = composition.naturalSize
        if composition.naturalSize != .zero && composition.naturalSize != movie.naturalSize {
            let text1 = "width: \(Int(movie.naturalSize.width)), height: \(Int(movie.naturalSize.height))"
            let text2 = "width: \(Int(currentMovieSize.width)), height: \(Int(currentMovieSize.height))"
            return (nil, .init(text: "Video size of inserted video (\(text1)) is not matching with the size of your video\nPlease select video with the size \(text2)"))
        }
        do {
            try composition.insertTimeRange(CMTimeRangeMake(start: .zero, duration: duration), of: movie, at: .zero)
            return (composition, nil)
        } catch {
            print(error.localizedDescription)
            return (nil, .init(text: error.localizedDescription))
        }
    }
   
    func createSaveVideo(_ url:URL?, addingVideo:Bool = false) async -> NSError? {
        let url = url ?? testURL
        let urlResult = await self.createVideo(url, addingVideo: true)
        if addingVideo, let stringUrl = urlResult.videoExportResponse?.url?.lastPathComponent {
            
            DB.db.movieParameters.editingMovie?.preview = delegate.movie?.tracks.first?.asset?.preview(time: .zero)?.jpegData(compressionQuality: 0)
        }
        return urlResult.videoExportResponse?.url != nil ? nil : (urlResult.error ?? NSError(text: "Error saving the video"))
    }
            
    private func filterAddedToComposition(_ url:URL?, videoComposition:AVMutableVideoComposition? = nil) async -> Bool {
        print("filterAddedToComposition")
        guard let url else {
            print("no url filterAddedToComposition")
            return false
        }
        let movie = AVURLAsset(url: url)
        if let localUrl = await export(asset: movie, videoComposition: videoComposition, isVideo: false).videoExportResponse?.url {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
            return true
        } else {
            return false
        }
    }
}

extension PrepareEditorModel {
    @MainActor func movieUpdated(movie:AVMutableComposition?,
                                 movieURL:URL?,
                                 canSetNil:Bool = true
    ) {
        if canSetNil || movie != nil {
            self.delegate.movie = movie
        }
        if canSetNil || movieURL != nil {
            self.delegate.movieURL = movieURL
        }
    }
}

// MARK: AVMutableComposition
extension PrepareEditorModel {
    func addSound(url:URL?) async -> Response {
        let composition = delegate.movie ?? .init()
        guard let url else {
            return .error(.init(title:"File not found", description: "looks like selected file is not downloaded to the device"))
        }
        let sound = AVURLAsset(url: url)

        guard let newAudio = sound.tracks.first(where: {$0.mediaType == .audio})
        else {
            print("error inserting audion: audio is empty, or asset is nil sound: \(sound) duration: \(sound.duration)")
            return .error(.init(title:"Not found audio in the selected file"))
        }
        do {
            let audioMutable = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try await audioMutable?.insertTimeRange(CMTimeRange(start: .zero, duration: composition.duration()), of: newAudio, at: .zero)
            let response = await export(asset: composition, videoComposition: nil, isVideo: false)
            if let url = response.videoExportResponse?.url {
                DB.db.movieParameters.editingMovie?.notFilteredURL = url.lastPathComponent
                await movieUpdated(movie: composition, movieURL: url, canSetNil: false)
            } else {
                return .init(error:response.error ?? .init(text: "Error adding sound into the composition"))
            }
            return response
        } catch {
            print(error, " error insering audio into composition")
            return .error(.init(title:error.localizedDescription, description: "Audio not inserted"))
        }
    }
    
    typealias compositionReponse = (composition: AVMutableComposition?, error: NSError?)
    
    final private func createComposition(_ urlAsset:AVURLAsset) async -> compositionReponse {
        let composition = AVMutableComposition()
        let segments = await loadSegments(asset: urlAsset)
        do {
            let firstAudio:AVAssetTrack!
            let firstOpt:AVAssetTrack!
            if #available(iOS 15.0, *) {
                firstOpt = try await urlAsset.loadTracks(withMediaType: .video).first
                firstAudio = try await urlAsset.loadTracks(withMediaType: .audio).first
            } else {
                firstOpt = urlAsset.tracks(withMediaType: .video).first
                firstAudio = urlAsset.tracks(withMediaType: .audio).first
            }
            if
                let value = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let first = firstOpt,
                let time = first.segments.first?.timeMapping.target
            {
               // value.preferredVolume = 0.2
                let range = CMTimeRangeMake(start: time.start, duration: time.duration)
                try value.insertTimeRange(range, of: first, at: time.start)
            }
            
            if
                let value = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
                let first = firstAudio,
                let time = first.segments.first?.timeMapping.target
            {
              //  value.preferredVolume = 0.2
                let range = CMTimeRangeMake(start: time.start, duration: time.duration)
                try value.insertTimeRange(range, of: first, at: time.start)
            }
        } catch {
            print("error creating composition from url ", error)
            return (nil, .init(text: error.localizedDescription))
        }
        return (composition, nil)
    }

    func loadSegments(asset:AVURLAsset?, isPreview:Bool = false) async -> [(AVAssetTrackSegment, AVAssetTrack)] {
        guard let asset = asset ?? delegate.movie else {
            return []
        }
        var results:[(AVAssetTrackSegment, AVAssetTrack)] = []
        var id:[String] = []
        do {
            let tracks:[AVAssetTrack]!
            if #available(iOS 15, *) {
                tracks = try await asset.load(.tracks)
            } else {
                tracks = asset.tracks
            }
            tracks.forEach {
                let track = $0
                let urlAsset = $0.asset as? AVURLAsset
                if $0.mediaType == .audio || $0.mediaType == .video && !id.contains(urlAsset?.url.absoluteString ?? "-1") {
                    if let url = urlAsset?.url.absoluteString {
                        id.append(url)
                    }
                    $0.segments.forEach {
                        results.append(($0, track))
                    }
                }
            }
            print("loaded segments count: ", results.count)
            return results
        } catch {
            print("Failed to insert track 1 into composition: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - video instructions
extension PrepareEditorModel {
    final private func allCombinedInstructions(composition: AVMutableComposition, assetTrack: [AVMutableCompositionTrack], videoSize: CGSize, overlayLayer:CALayer, assetData:[MovieAttachmentProtocol]? = nil) async -> AVMutableVideoComposition? {
        var data:[MovieAttachmentProtocol] = assetData ?? DB.db.movieParameters.editingMovie?.images ?? []
        if assetData == nil {
            DB.db.movieParameters.editingMovie?.texts.forEach({
                data.append($0)
            })
        }
        var compositions:[AVVideoComposition] =  []
        var layers:[(CALayer, CALayer)] = []
        for row in data {
            let results = await addLayerComposition(composition: composition, assetTrack: assetTrack, layer: overlayLayer, data: row, videoSize: videoSize)
            if let value = results?.0 {
                compositions.append(value)
                layers.append((results!.1, results!.2))
            }
            
        }
        
        return await combineVideoCompositions(compositions: compositions, size: videoSize, videoDuration: composition.duration(), layers: layers)
    }
    
    private func combineVideoCompositions(compositions: [AVVideoComposition], size:CGSize, videoDuration:CMTime?, layers:[(CALayer, CALayer)]) -> AVMutableVideoComposition? {
        let res = AVMutableVideoComposition()
        var layerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        
        for composition in compositions {
            let animationLayer = CALayer()
            animationLayer.frame = CGRect(origin: .zero, size: size)
            animationLayer.isGeometryFlipped = true
            
            let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: animationLayer, in: animationLayer)
            
            if res.animationTool == nil {
                res.animationTool = animationTool
            } else {
                res.animationTool = AVVideoCompositionCoreAnimationTool(
                    additionalLayer: animationLayer,
                    asTrackID: Int32(layers.count)
                )
            }
            guard let instructions = composition.instructions as? [AVVideoCompositionInstruction] else {
                continue
            }
            
            for instruction in instructions {
                res.instructions.append(instruction)
            }
            for instruction in composition.instructions as! [AVVideoCompositionInstruction] {
                for layerInstruction in instruction.layerInstructions as! [AVMutableVideoCompositionLayerInstruction] {
                    let clonedLayerInstruction = layerInstruction.mutableCopy() as! AVMutableVideoCompositionLayerInstruction
                    
                    layerInstructions.append(clonedLayerInstruction)
                }
            }
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: videoDuration ?? .zero)
        mainInstruction.layerInstructions = layerInstructions
        let vidLayer = CALayer()
        vidLayer.frame = .init(origin: .zero, size: size)
        let outputLayer = CALayer()
        outputLayer.frame = .init(origin: .zero, size: size)
        outputLayer.addSublayer(vidLayer)
        layers.forEach {
            $0.0.frame = .init(origin: .zero, size: size)
            $0.1.frame = .init(origin: .zero, size: size)
            vidLayer.addSublayer($0.0)
            outputLayer.addSublayer($0.1)
        }
        res.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: vidLayer,
            in: outputLayer)/* compositions.last(where: {$0.animationTool != nil && $0.instructions.count != 0})?.animationTool ?? AVVideoCompositionCoreAnimationTool(
                             postProcessingAsVideoLayer: vidLayer,
                             in: outputLayer)*/
        res.renderSize = size
        res.frameDuration = VideoEditorModel.fmp30
        print(res.instructions, " terfwd")
        res.instructions = [mainInstruction]
        return res
    }
    

    private func addLayerComposition(composition: AVMutableComposition, assetTrack: [AVMutableCompositionTrack], layer:CALayer, data:MovieAttachmentProtocol?, videoSize: CGSize) async -> (AVMutableVideoComposition?, CALayer, CALayer)? {
        let ok = await layerEditor.addLayer(to: layer,
                                   videoSize: videoSize,
                                   data: data, videoTotalTime: composition.duration().seconds)
        if !ok {
            return nil
        }
        let videoComposition = await layerEditor.videoComposition(assetTrack: assetTrack, overlayLayer: layer, composition: composition)
        print(videoComposition?.0.instructions, " htgefrdwe")
        return videoComposition
    }
    
    private var testURL:URL? {
        return Bundle.main.url(forResource: "1", withExtension: "mov") ?? Bundle.main.url(forResource: "1", withExtension: "mp4")
    }
}


protocol PrepareEditorModelDelegate {
    var movie:AVMutableComposition? { get set }
    var movieHolder:AVMutableComposition?{ get set}
    var movieURL:URL? {get set}
}

