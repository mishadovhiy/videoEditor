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
    
    @MainActor func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?, isVideo:Bool, isQuery:Bool = false) async -> Response {
        print(asset.duration, " export duration")
        guard let composition = delegate.movieHolder ?? delegate.movie
        else {
            print("error movieHolder and no delegate.movie", #file, #line, #function)
            return .error(.init(title:"Error exporting the video", description: "Try reloading the app"))
        }
        let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        let results = await export?.exportVideo(videoComposition: videoComposition, isVideoAdded: isVideo)
        return results ?? .error("Unknown Error")
    }
    
    func addText() async -> Response {
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

    func createVideo(_ url:URL?, needExport:Bool = true, replaceVideo:Bool = false) async -> Response {
        let movie = delegate.movie ?? .init()
        guard let url else {
            return .error("File not found")
        }
        let newMovie = await createComposition(AVURLAsset(url: url))//AVURLAsset(url: url)
        print(newMovie.composition?.duration, " inserted video duration")
        guard await newMovie.composition?.duration() != .zero,
              let _ = await insertMovie(movie: newMovie.composition, composition: movie) else {
            return .error("Error inserting video")
        }
        delegate.movieHolder = movie
        if needExport {
            let localUrl = await export(asset: movie, videoComposition: nil, isVideo: true)
            if let _ = localUrl.videoExportResponse?.url {
                await self.movieUpdated(movie: movie, movieURL: localUrl.videoExportResponse?.url)
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
                await self.filterAddedToComposition(url, videoComposition: self.videoCompositionHolder)
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
    private func insertMovie(movie:AVMutableComposition?, composition:AVMutableComposition) async -> AVMutableComposition? {
        guard let movie else {
            return nil
        }
        let duration = await movie.duration()
        print(duration, " total coposition duration before insert")
        movieDescription(movie: composition, duration: duration)
        do {
            let range = CMTimeRangeMake(start: .zero, duration: duration)
            try composition.insertTimeRange(range, of: movie, at: .zero)
            
            return composition
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func createTestBundleVideo(_ url:String, addingVideo:Bool = false) async -> Bool {
        guard let url = Bundle.main.url(forResource: url, withExtension: "mov") ?? Bundle.main.url(forResource: url, withExtension: "mp4") else {
            return false
        }
        let urlResult = await self.createVideo(url).videoExportResponse?.url
        if addingVideo, let stringUrl = urlResult?.lastPathComponent {
            DB.db.movieParameters.editingMovie?.originalURL = stringUrl
            DB.db.movieParameters.editingMovie?.preview = delegate.movie?.tracks.first?.asset?.preview(time: .zero)?.jpegData(compressionQuality: 0.01)
        }
        return urlResult != nil
    }
        
    private func movieDescription(movie:AVMutableComposition, duration: CMTime) {
        var vids = 0
        movie.tracks.forEach {
            vids += ($0.asset?.tracks.count ?? 0)
            print("tracks: ", $0.asset?.tracks ?? [])
            print(vids, " video count")
            print($0.asset.debugDescription, " asset")
        }
        movie.tracks(withMediaType: .video).forEach {
            print($0.segments.count, " rtehytbrt")
            $0.segments.forEach {
                let time = $0.timeMapping.source
                print("startFrom: ", time.start)
                print("startDuration: ", time.duration.seconds)
                
                print($0.description, " video description")
            }
        }
        print(vids, " total vids")
        print(movie, " total movie")
        print(duration, " total duration ")
    }
    
    private func filterAddedToComposition(_ url:URL?, videoComposition:AVMutableVideoComposition? = nil) async {
        print("filterAddedToComposition")
        guard let url else {
            print("no url filterAddedToComposition")
            return
        }
        let movie = AVURLAsset(url: url)
        if let localUrl = await export(asset: movie, videoComposition: videoComposition, isVideo: false).videoExportResponse?.url {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
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
            try segments.forEach {
                if ($0.1.mediaType == .video || $0.1.mediaType == .audio), let _ = composition.addMutableTrack(withMediaType: $0.1.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) {
                    let range = CMTimeRangeMake(start: $0.0.timeMapping.target.start, duration: $0.0.timeMapping.target.duration)
                    
                    try composition.insertTimeRange(range, of: $0.1.asset!, at: $0.0.timeMapping.target.start)
                }
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
            try await asset.load(.tracks).forEach {
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
    final private func allCombinedInstructions(composition: AVMutableComposition, assetTrack: [AVMutableCompositionTrack], videoSize: CGSize, overlayLayer:CALayer) async -> AVMutableVideoComposition? {
        ///mask single composition
        //                await layerEditor.addLayer(to: overlayLayer,
        //                                     videoSize: videoSize,
        //                                     text: .init(attachment: data), videoTotalTime: asset.duration().seconds)
        //                let videoComposition = await layerEditor.videoComposition(assetTrack: assetTrack, overlayLayer: overlayLayer, composition: composition)
        
        let data = DB.db.movieParameters.editingMovie?.texts ?? []
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
            animationLayer.frame = CGRect(origin: .zero, size: composition.renderSize)
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
        guard let data else {
            return nil
        }
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
}


protocol PrepareEditorModelDelegate {
    var movie:AVMutableComposition? { get set }
    var movieHolder:AVMutableComposition?{ get set}
    var movieURL:URL? {get set}
}

