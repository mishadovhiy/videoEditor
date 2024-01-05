//
//  EditorVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

struct EditorVideoLayer {
    
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
    
    func addLayer(text: String, to layer: CALayer, videoSize: CGSize) {
        self.add(text: text, to: layer, videoSize: videoSize)
    }
}


//MARK: add layers
fileprivate extension EditorVideoLayer {
    
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
    
    
    func add(text: String, to layer: CALayer, videoSize: CGSize) {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 100, weight: .bold) as Any,
                .foregroundColor: UIColor.green.cgColor,
                .strokeColor: UIColor.white,
                .strokeWidth: -3])
        
        let textLayer = CATextLayer()
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        
        textLayer.frame = CGRect(
            x: 0,
            y: 200,
            width: videoSize.width,
            height: 150)
        textLayer.displayIfNeeded()
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        scaleAnimation.isRemovedOnCompletion = false
        textLayer.add(scaleAnimation, forKey: "scale")
        layer.addSublayer(textLayer)
    }
}

//MARK: Setup
fileprivate extension EditorVideoLayer {
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        instruction.setTransform(transform, at: .zero)
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


fileprivate extension EditorVideoLayer {
    
    func videoInstractions(composition:AVMutableComposition, track:AVAssetTrack, overlayLayer: CALayer?) -> InstractionsResult {
        let videoSize = videoSize(assetTrack: track)
        print(videoSize, " videoSizevideoSizevideoSize")
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .init(x: 20, y: 20), size: .init(width: videoSize.width - 40, height: videoSize.height - 40))
        videoLayer.backgroundColor = UIColor.red.cgColor
        let outputLayer = CALayer()
        outputLayer.backgroundColor = UIColor.red.cgColor
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
            start: .zero,
            duration: composition.duration)
        videoComposition.instructions = [instruction]
        return .init(instractions: instruction, composition: videoComposition)
    }
}


fileprivate extension EditorVideoLayer {
    struct InstractionsResult {
        let instractions:AVMutableVideoCompositionInstruction
        let composition:AVMutableVideoComposition
    }
}
