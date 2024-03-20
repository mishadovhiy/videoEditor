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
    
    func videoComposition(assetTrack:[AVAssetTrack], overlayLayer: CALayer?, composition:AVMutableComposition) async -> (AVMutableVideoComposition, CALayer, CALayer)? {
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
        return (instraction.composition, instraction.videoLayer, instraction.outputLayer)
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
    
    func addLayer(to layer: CALayer, videoSize: CGSize, data:MovieAttachmentProtocol, videoTotalTime:CGFloat) -> Bool {
        if let newValue = attachmentLayer.add(to: layer, videoSize: videoSize, data: data) {
            animation.add(newValue, to: layer, data:data, totalTime: videoTotalTime)
            return true
        } else {
            print("video not added \(data) ", #file, #line)
            return false
        }
    }
    
    func loadAudioMix(volume:Float) -> AVMutableAudioMix? {
        let mixParams = AVMutableAudioMixInputParameters()
        mixParams.setVolume(volume, at: CMTime.zero)
        
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = [mixParams]
        return audioMix
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
        videoComposition.frameDuration = VideoEditorModel.fmp30
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        print("instractions dusration: ", track.asset?.duration ?? .zero)
        instruction.timeRange = await CMTimeRange(
            start: .zero,
            duration: composition.duration())
        videoComposition.instructions = [instruction]
        return .init(instractions: instruction, composition: videoComposition, videoLayer:videoLayer, outputLayer:outputLayer)
    }
    
    struct InstractionsResult {
        let instractions:AVMutableVideoCompositionInstruction
        let composition:AVMutableVideoComposition
        var videoLayer:CALayer
        var outputLayer:CALayer
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

