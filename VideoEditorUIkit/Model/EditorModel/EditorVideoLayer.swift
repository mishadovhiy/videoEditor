//
//  EditorVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

struct EditorVideoLayer {
    
    let attachmentLayer:AttachentVideoLayerModel
    let animation:AnimateVideoLayer
    
    init() {
        self.attachmentLayer = .init()
        self.animation = .init()
    }
    
    func videoComposition(assetTrack:[AVAssetTrack], overlayLayer: CALayer?, composition:AVMutableComposition) -> AVMutableVideoComposition? {
        var tracks:[AVMutableCompositionTrack] = []
        assetTrack.forEach({
            if let compositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) {
                tracks.append(compositionTrack)
                do {
                    try compositionTrack.insertTimeRange(.init(start: .zero, duration: $0.asset!.duration), of: $0, at: .zero)
                } catch {  }
            }
            
        })
        let instraction = videoInstractions(track: tracks.first!, overlayLayer: overlayLayer)
        let secondLayer = CALayer()
        secondLayer.frame = .init(origin: .zero, size: .init(width: (overlayLayer?.bounds.width ?? 0) / 2, height: (overlayLayer?.bounds.height ?? 0) / 2))
        secondLayer.backgroundColor = UIColor.red.cgColor
        secondLayer.borderWidth = 5
        secondLayer.borderColor = UIColor.green.cgColor
        overlayLayer?.addSublayer(secondLayer)
        let instraction2 = videoInstractions(track: tracks.first!, overlayLayer: secondLayer)

        var i = 0
        assetTrack.forEach({
            let layerInstruction = compositionLayerInstruction(
                for: tracks[i],
                assetTrack: $0)
            i += 1
            instraction.instractions.layerInstructions.append(layerInstruction)
            instraction2.instractions.layerInstructions.append(layerInstruction)
        })
        return instraction.composition
    }
    
    func videoSize(assetTrack:AVAssetTrack) -> CGSize {
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        let size = assetTrack.naturalSize
        if videoInfo.isPortrait {
            return .init(width: size.height, height: size.width)
        } else {
            return size
        }
    }
    
    func addLayer(text: String, to layer: CALayer, videoSize: CGSize, videoDuration:CGFloat) {
        let newValue = attachmentLayer.add(text: text, to: layer, videoSize: videoSize)
        animation.add(newValue, to: layer, duration: videoDuration, properties: .init())
    }
    
    func addLayer(video: String, to layer: CALayer, videoSize: CGSize, videoDuration:CGFloat) {
        let newValue = attachmentLayer.add(video: video, to: layer, videoSize: videoSize)
        animation.add(newValue, to: layer, duration: videoDuration, properties: .init(needScale: false))
    }
}


//MARK: add layers
fileprivate extension EditorVideoLayer {
    
    private func videoInstractions(track:AVAssetTrack, overlayLayer: CALayer?) -> InstractionsResult {
        let videoSize = videoSize(assetTrack: track)
        print(videoSize, " videoSizevideoSizevideoSize")
        let videoLayer = CALayer()
        let size:CGSize = overlayLayer?.frame.size ?? .init(width: 10, height: 10)
        videoLayer.frame = .init(origin: .zero, size: .init(width: size.width - 10, height: size.height - 10))
        //CGRect(origin: .init(x: 20, y: 20), size: .init(width: videoSize.width - 40, height: videoSize.height - 40))
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
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: track.asset?.duration ?? .zero)
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
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        instruction.setTransform(transform, at:.zero)
        return instruction
    }
    
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

