//
//  EditorLayerModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

struct PrepareEditorModel {
    
    var delegate:PrepareEditorModelDelegate!
    private let layerEditor:EditorVideoLayer
    private var compositionHolder:AVMutableComposition?
    
    init(delegate: PrepareEditorModelDelegate) {
        self.delegate = delegate
        self.layerEditor = .init()
    }
    
    mutating func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?, isVideo:Bool, isQuery:Bool = false) async -> URL? {
        print("exportexporting ", asset.duration)
        guard let composition = toComposition(asset: asset, addingVideo: isVideo)
        else {
            print("Cannot create export session.")
            return nil
        }
        let export = AVAssetExportSession(composition: composition)
        let results = await export?.exportVideo(videoComposition: videoComposition)
        if isVideo {
            compositionHolder = composition
        }
        return results
    }
    
    
    mutating func addText(data:MovieAttachmentProtocol) async -> Bool {
        let asset = delegate.movie ?? .init()
        guard let composition = addTextComposition(asset: asset)
        else { return false }
        let assetTrack = asset.tracks(withMediaType: .video)
        let videoSize = layerEditor.videoSize(assetTrack: assetTrack.first!)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        layerEditor.addLayer(to: overlayLayer,
            videoSize: videoSize, 
                             text: data as? TextAttachmentDB ?? .demo)
//        layerEditor.addLayer(
//            video: "Happy Birthday,\n-",
//            to: overlayLayer,
//            videoSize: videoSize, videoDuration: asset.duration.seconds)
        let videoComposition = layerEditor.videoComposition(assetTrack: assetTrack, overlayLayer: overlayLayer, composition: composition)
        if let localUrl = await export(asset: composition, videoComposition: videoComposition, isVideo: false) {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
            return true
        } else {
            return false
        }
    }
    
    mutating func createVideo(_ url:String) async -> Bool {
        guard let url = Bundle.main.url(forResource: url, withExtension: "mov") ?? Bundle.main.url(forResource: url, withExtension: "mp4") else {
            return false
        }
        return await self.createVideo(url)
    }
}



fileprivate extension PrepareEditorModel {
    
    private func toComposition(asset:AVAsset, addingVideo:Bool) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let duration = CMTime(seconds: asset.duration.seconds, preferredTimescale: EditorModel.timeScale)
        asset.tracks(withMediaType: .video).forEach( {
            let sourceAudioTrack = $0
            do {
                try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: duration), of: sourceAudioTrack, at: CMTime.zero)
            } catch { }
        })
        if addingVideo {
            let audio = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            let audioDuration = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            
            do {
                if let first = asset.tracks(withMediaType: .audio).first {
                    try audio?.insertTimeRange(audioDuration, of: first, at: CMTime.zero)
                }
            } catch {
                print("Failed to insert audio into composition: \(error)")
            }
        }
        
        return composition
    }
    
    
    private func addTextComposition(asset:AVAsset) -> AVMutableComposition? {
      //  return toComposition(asset: asset, addingVideo: true)
        let composition = AVMutableComposition()
        let duration = CMTime(seconds: asset.duration.seconds, preferredTimescale: EditorModel.timeScale)
        let timeRange = CMTimeRange(start: .zero, duration: duration)
        asset.tracks(withMediaType: .audio).forEach {
            let audioAssetTrack = $0
            do {
                if let compositionAudioTrack = composition.addMutableTrack(
                    withMediaType: audioAssetTrack.mediaType,
                    preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try compositionAudioTrack.insertTimeRange(
                        timeRange,
                        of: audioAssetTrack,
                        at: .zero)
                }
            }
            catch {}
        }
        return composition
    }
}


extension PrepareEditorModel {
    mutating func createVideo(_ url:URL?) async -> Bool {
        let movie = delegate.movie ?? .init()
        guard let url else {
            return false
        }
        let newMovie = AVURLAsset(url: url)
        do {
            let duration = try await newMovie.load(.duration)
            let range = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            try movie.insertTimeRange(range, of: newMovie, at: .zero)
            
            print(movie, " movie performAddVideo")
            if let localUrl = await export(asset: movie, videoComposition: nil, isVideo: true) {
                await self.movieUpdated(movie: movie, movieURL: localUrl)
                return true
            }
            return false
        } catch let error {
            print(error.localizedDescription, " parformAddVideoparformAddVideo")
            return false
        }
    }

}

extension PrepareEditorModel {
    @MainActor mutating func movieUpdated(movie:AVMutableComposition?,
                                          movieURL:URL?,
                                          canSetNil:Bool = true
    ) {
        if !(!canSetNil && movie == nil) {
            self.delegate.movie = movie
        }
        self.delegate.movieURL = movieURL
    }
}

protocol PrepareEditorModelDelegate {
    var movie:AVMutableComposition? { get set }
    var movieURL:URL? {get set}
}
