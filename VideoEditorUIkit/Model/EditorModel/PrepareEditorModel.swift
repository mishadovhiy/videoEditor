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
    private var filterEndedLoading:((Bool)->())?
    
    init(delegate: PrepareEditorModelDelegate) {
        self.delegate = delegate
        self.layerEditor = .init()
    }
    
    deinit {
        delegate = nil
    }
    
    @MainActor func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?, isVideo:Bool, isQuery:Bool = false) async -> URL? {
        print(asset.duration, " export duration")
        guard let composition = delegate.movieHolder ?? delegate.movie
        else {
            print("Cannot create export session.")
            return nil
        }
        let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        let results = await export?.exportVideo(videoComposition: videoComposition, isVideoAdded: isVideo)
        return results
    }
    
    func addText() async -> Bool {
        let asset = delegate.movie ?? .init()
        print(asset.duration, " video duration")
        guard let composition = delegate.movieHolder
        else {
            return false }
        let assetTrack = asset.tracks(withMediaType: .video)
        guard let firstTrack = assetTrack.first(where: {$0.naturalSize.width != 0}) else {
            return false
        }
        let videoSize = layerEditor.videoSize(assetTrack: firstTrack)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        let videoComposition = await allCombinedInstructions(composition: composition, assetTrack: assetTrack, videoSize: videoSize, overlayLayer: overlayLayer)
        delegate.movieHolder = composition
        if let localUrl = await export(asset: composition, videoComposition: videoComposition, isVideo: false) {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
            return true
        } else {
            return false
        }
    }

    func createVideo(_ url:URL?, needExport:Bool = true, replaceVideo:Bool = false) async -> URL? {
        let movie = delegate.movie ?? .init()
        guard let url else {
            return nil
        }
        let newMovie = await createComposition(AVURLAsset(url: url))//AVURLAsset(url: url)
        print(newMovie?.duration, " inserted video duration")
        guard await newMovie?.duration() != .zero,
              let _ = await insertMovie(movie: newMovie, composition: movie) else {
            return nil
        }
        delegate.movieHolder = movie
        if needExport {
            guard let localUrl = await export(asset: movie, videoComposition: nil, isVideo: true) else {
                return nil
            }
            await self.movieUpdated(movie: movie, movieURL: localUrl)
            return localUrl
        } else {
            return nil
        }
    }
    
    func addFilter(completion:@escaping()->()) async {
        let movie = delegate.movieHolder ?? delegate.movie!
        let video = VideoFilter.addFilter(composition: movie, completion: { url in
            Task {
                await self.filterAddedToComposition(url)
                await MainActor.run {
                    completion()
                }
            }
        })
        
        if let localUrl = await export(asset: movie, videoComposition: video, isVideo: false) {
            await self.movieUpdated(movie: movie, movieURL: localUrl, canSetNil: false)
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
        let urlResult = await self.createVideo(url)
        if addingVideo, let stringUrl = urlResult?.lastPathComponent {
            DB.db.movieParameters.editingMovie?.originalURL = stringUrl
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
    
    private func filterAddedToComposition(_ url:URL?) async {
        print("filterAddedToComposition")
        guard let url else {
            return
        }
        let movie = AVURLAsset(url: url)
        if let localUrl = await export(asset: movie, videoComposition: nil, isVideo: false) {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
            filterEndedLoading?(true)
            filterEndedLoading = nil
        } else {
            filterEndedLoading?(false)
            filterEndedLoading = nil
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
    func addSound(url:URL?) async -> Bool {
        let composition = delegate.movie ?? .init()
        guard let url else {
            return false
        }
        let sound = AVURLAsset(url: url)

        guard let newAudio = sound.tracks.first(where: {$0.mediaType == .audio}),
              let newAsset = newAudio.asset
        else {
            print("error inserting audion: audio is empty, or asset is nil sound: \(sound) duration: \(sound.duration)")
            return false
        }
        do {
            let audioMutable = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try await audioMutable?.insertTimeRange(CMTimeRange(start: .zero, duration: composition.duration()), of: newAudio, at: .zero)
            if let url = await export(asset: composition, videoComposition: nil, isVideo: false) {
                await movieUpdated(movie: composition, movieURL: url, canSetNil: false)
                return true
            } else {
                return false
            }
        } catch {
            print(error, " error insering audio into composition")
            return false
        }
    }
    
    final private func createComposition(_ urlAsset:AVURLAsset) async -> AVMutableComposition? {
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
            return nil
        }
        return composition
    }

    func loadSegments(asset:AVURLAsset?) async -> [(AVAssetTrackSegment, AVAssetTrack)] {
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
        res.frameDuration = EditorModel.fmp30
        print(res.instructions, " terfwd")
        res.instructions = [mainInstruction]
        return res
    }
    

    private func addLayerComposition(composition: AVMutableComposition, assetTrack: [AVMutableCompositionTrack], layer:CALayer, data:TextAttachmentDB?, videoSize: CGSize) async -> (AVMutableVideoComposition?, CALayer, CALayer)? {
        
        await layerEditor.addLayer(to: layer,
                                   videoSize: videoSize,
                                   text: .init(attachment: data), videoTotalTime: composition.duration().seconds)
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

