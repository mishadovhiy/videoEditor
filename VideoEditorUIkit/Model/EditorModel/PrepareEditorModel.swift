//
//  EditorLayerModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

struct PrepareEditorModel {
    
    var delegate:PrepareEditorModelDelegate
    private let layerEditor:EditorVideoLayer
    
    init(delegate: PrepareEditorModelDelegate) {
        self.delegate = delegate
        self.layerEditor = .init()
    }
    
    
    func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?) async -> URL? {
        guard let composition = toComposition(asset: asset)
        else {
            print("Cannot create export session.")
            return nil
        }
        let export = AVAssetExportSession(composition: composition)
        return await export?.exportVideo(videoComposition: videoComposition)
    }
    
    
    mutating func addText() async -> Bool {
        let asset = delegate.movie ?? .init()
        guard let composition = addTextComposition(asset: asset)
        else { return false }
        let assetTrack = asset.tracks(withMediaType: .video)
        let videoSize = layerEditor.videoSize(assetTrack: assetTrack.first!)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        layerEditor.addLayer(
            text: "Happy Birthday,\n-",
            to: overlayLayer,
            videoSize: videoSize, videoDuration: asset.duration.seconds)
//        layerEditor.addLayer(
//            video: "Happy Birthday,\n-",
//            to: overlayLayer,
//            videoSize: videoSize, videoDuration: asset.duration.seconds)
        let videoComposition = layerEditor.videoComposition(assetTrack: assetTrack, overlayLayer: overlayLayer, composition: composition)
        if let localUrl = await export(asset: composition, videoComposition: videoComposition) {
            self.delegate.movieURL = localUrl
            return true
        } else {
            return false
        }
    }
    
    
    mutating func createVideo(_ url:String) async -> Bool {
        let movie = delegate.movie ?? .init()
        guard let url = Bundle.main.url(forResource: url, withExtension: "mov") else {
            fatalError()
        }
        let newMovie = AVURLAsset(url: url)
        do {
            let duration = try await newMovie.load(.duration)
            let range = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            try movie.insertTimeRange(range, of: newMovie, at: .zero)
            
            print(movie, " movie performAddVideo")
            if let localUrl = await export(asset: movie, videoComposition: nil) {
                self.delegate.movie = movie
                self.delegate.movieURL = localUrl
                return true
            }
            return false
        } catch let error {
            print(error.localizedDescription, " parformAddVideoparformAddVideo")
            return false
        }
    }
}



fileprivate extension PrepareEditorModel {
    
    private func toComposition(asset:AVAsset) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let duration = CMTime(seconds: asset.duration.seconds, preferredTimescale: EditorModel.timeScale)
        asset.tracks(withMediaType: .video).forEach( {
            let sourceAudioTrack = $0
            do {
                try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: duration), of: sourceAudioTrack, at: CMTime.zero)
            } catch { }
        })
        return composition
    }
    
    
    private func addTextComposition(asset:AVAsset) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
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


protocol PrepareEditorModelDelegate {
    var movie:AVMutableComposition? { get set }
    var movieURL:URL? {get set}
}
