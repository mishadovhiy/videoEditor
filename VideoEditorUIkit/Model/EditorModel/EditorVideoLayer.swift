//
//  EditorVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

struct EditorVideoLayer {
    
    private let attachmentLayer:AttachentVideoLayerModel
    private let animation:AnimateVideoLayer
    
    init() {
        self.attachmentLayer = .init()
        self.animation = .init()
    }
    
    func videoComposition(assetTrack:[AVAssetTrack], overlayLayer: CALayer?, composition:AVMutableComposition) async -> AVMutableVideoComposition? {
        let tracks:[AVMutableCompositionTrack] = composition.tracks(withMediaType: .video)
        
        overlayLayer?.isGeometryFlipped = true
        let firstTrack = tracks.first(where: {$0.naturalSize.width != 0})
        let instraction = await videoInstractions(track: firstTrack!, overlayLayer: overlayLayer, composition: composition)
        if let first = firstTrack {
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: first)
            let transform = first.preferredTransform
            layerInstruction.setTransform(transform, at:.zero)
            instraction.instractions.layerInstructions.append(layerInstruction)
        }
        return instraction.composition
    }
    
    func videoSize(assetTrack:AVAssetTrack) -> CGSize {
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        let size = assetTrack.naturalSize
        if videoInfo.isPortrait {
            return size//.init(width: size.height, height: size.width)
        } else {
            return size
        }
    }
    
    func addLayer(to layer: CALayer, videoSize: CGSize, text:TextAttachmentDB, videoTotalTime:CGFloat) {
        let newValue = attachmentLayer.add(to: layer, videoSize: videoSize, text: text)
        animation.add(newValue, to: layer, start: text.inMovieStart, duration: text.duration, totalTime: videoTotalTime, properties: .init(needScale: text.needScale))
    }
    
    func addLayer(video: String, to layer: CALayer, videoSize: CGSize, videoDuration:CGFloat, attachmantStart:CGFloat, attachmantDuration:CGFloat) {
        let newValue = attachmentLayer.add(video: video, to: layer, videoSize: videoSize)
        animation.add(newValue, to: layer, start: attachmantStart, duration: attachmantDuration, totalTime: videoDuration, properties: .init(needScale: false))
    }
}


//MARK: add layers
fileprivate extension EditorVideoLayer {
    
    private func videoInstractions(track:AVAssetTrack, overlayLayer: CALayer?, composition:AVMutableComposition) async -> InstractionsResult {
        let videoSize = videoSize(assetTrack: track)
        let videoLayer = CALayer()
        let size:CGSize = overlayLayer?.frame.size ?? .init(width: 10, height: 10)
        videoLayer.frame = .init(origin: .zero, size: size)
        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        outputLayer.addSublayer(videoLayer)
        if let overlayLayer {
            outputLayer.addSublayer(overlayLayer)
        }
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = EditorModel.fmp30
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        print("instractions dusration: ", track.asset?.duration ?? .zero)
        instruction.timeRange = await CMTimeRange(
            start: .zero,
            duration: composition.duration())
        videoComposition.instructions = [instruction]
        return .init(instractions: instruction, composition: videoComposition)
    }

    struct InstractionsResult {
        let instractions:AVMutableVideoCompositionInstruction
        let composition:AVMutableVideoComposition
    }
}

//MARK: Setup
fileprivate extension EditorVideoLayer {
    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
}

