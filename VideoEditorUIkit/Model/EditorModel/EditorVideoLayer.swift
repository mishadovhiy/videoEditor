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
    
    init() {
        self.attachmentLayer = .init()
    }
    
    func videoComposition(assetTrack:[AVAssetTrack], overlayLayer: CALayer?, composition:AVMutableComposition) -> AVMutableVideoComposition? {
        return videoLayer(assetTrack: assetTrack, overlayLayer: overlayLayer, composition: composition)
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
        self.add(newLayer: newValue, to: layer, duration: videoDuration)
    }
}


//MARK: add layers
fileprivate extension EditorVideoLayer {
    
    func videoInstractions(composition:AVMutableComposition, track:AVAssetTrack, overlayLayer: CALayer?) -> InstractionsResult {
        let videoSize = videoSize(assetTrack: track)
        print(videoSize, " videoSizevideoSizevideoSize")
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .init(x: 20, y: 20), size: .init(width: videoSize.width - 40, height: videoSize.height - 40))
        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        outputLayer.addSublayer(videoLayer)
        if let overlayLayer {
            outputLayer.addSublayer(overlayLayer)
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .init(seconds: 0, preferredTimescale: EditorModel.timeScale),
            duration: .init(seconds: composition.duration.seconds, preferredTimescale: EditorModel.timeScale))
        videoComposition.instructions = [instruction]
        return .init(instractions: instruction, composition: videoComposition)
    }
    
    
    func videoLayer(assetTrack:[AVAssetTrack], overlayLayer: CALayer?, composition:AVMutableComposition) -> AVMutableVideoComposition? {
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
        
        let layer = overlayLayer!.sublayers!.first(where: {$0.name == "CATextLayer"})!
        let instraction = videoInstractions(composition: composition, track: tracks.first!, overlayLayer: overlayLayer)
        var i = 0
        assetTrack.forEach({
            let layerInstruction = compositionLayerInstruction(
                for: tracks[i],
                assetTrack: $0)
            i += 1
            instraction.instractions.layerInstructions.append(layerInstruction)
        })
        return instraction.composition
    }
}

//MARK: Setup
fileprivate extension EditorVideoLayer {
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        instruction.setTransform(transform, at:.zero)
      //  instruction.setTransform(CGAffineTransform(rotationAngle: CGFloat.pi / 4), at: .init(value: 2, timescale: EditorModel.timeScale))
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



//MARK: Animations

fileprivate extension EditorVideoLayer {
    
    func add(newLayer:CALayer, to layer: CALayer, duration:CGFloat) {
        newLayer.opacity = 0

        let show = CABasicAnimation(keyPath: "opacity")
        show.fromValue = 0
        show.toValue = 1
        show.duration = 0.8
        show.beginTime = duration * 0.2
        show.isRemovedOnCompletion = false
        newLayer.add(show, forKey: "show")

        let hide = CABasicAnimation(keyPath: "opacity")
        hide.fromValue = 1
        hide.toValue = 0
        hide.duration = 0.8
        hide.beginTime = duration * 0.8
        hide.isRemovedOnCompletion = false
        newLayer.add(hide, forKey: "hide")

        let vidible = CABasicAnimation(keyPath: "opacity")
        vidible.fromValue = 1
        vidible.toValue = 1
        vidible.duration = 0.1
        vidible.repeatCount = .greatestFiniteMagnitude
        vidible.beginTime = show.beginTime + show.duration
        vidible.repeatDuration = (hide.beginTime) - (vidible.duration + show.duration + show.beginTime + -0.1)
        newLayer.add(vidible, forKey: "vidible")
        
        layer.addSublayer(newLayer)
    }
}



fileprivate extension EditorVideoLayer {
    struct InstractionsResult {
        let instractions:AVMutableVideoCompositionInstruction
        let composition:AVMutableVideoComposition
    }
}
