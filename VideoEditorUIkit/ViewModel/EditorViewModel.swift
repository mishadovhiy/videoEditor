//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

class EditorViewModel {
    var presenter:ViewModelPresenter?
    var model:TrackAppearenceModel? = TrackAppearenceModel(count: [.init(width: 10, title: "aa")])
    
    init(presenter:ViewModelPresenter) {
        self.presenter = presenter
    }
    
    deinit {
        presenter = nil
        model = nil
    }
    
    func addVideo(text:Bool) {
        let text = true
        Task {
            if await addTestVideos() {
                if text {
                    //save add text minute, etc and add from scratch each time video added
                    ///bacause: addVideo - to avmutating, that doesnt contains calayer
                    if await addText(toVideoURL: self.presenter!.movieURL) {
                        await presenter?.videoAdded()
                    } else {
                        await presenter?.errorAddingVideo()
                    }
                } else {
                    await presenter?.videoAdded()
                }
                
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
    
    
    func addText(toVideoURL:URL?) async -> Bool {
        let asset = await movie()
        guard let composition = addTextComposition(asset: asset)
        else {
            return false
        }
        let assetTrack = asset.tracks(withMediaType: .video)
        let videoSize = videoSize(assetTrack: assetTrack.first!)
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        backgroundLayer.backgroundColor = UIColor.green.cgColor
        backgroundLayer.contents = UIImage(named: "background")?.cgImage
        backgroundLayer.contentsGravity = .resizeAspectFill
        
        add(
            text: "Happy Birthday,\n-",
            to: overlayLayer,
            videoSize: videoSize)
        
        
        let videoComposition = videoLayer(assetTrack: assetTrack, background: backgroundLayer, overlayLayer: overlayLayer, composition: composition)
        if let localUrl = await export(asset: composition, videoComposition: videoComposition) {
          //  self.presenter?.movie = composition
            self.presenter?.movieURL = localUrl
            return true
        } else {
            return false
        }
        
    }

    
    private func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?) async -> URL? {
        guard let composition = toComposition(asset: asset),
              let export = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            return nil
        }
        
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mp4")
        if let videoComposition {
            export.videoComposition = videoComposition
            
        } else {
        }
        export.metadata = []
        export.shouldOptimizeForNetworkUse = true
        export.timeRange = .init(start: .zero, duration: asset.duration)
        export.outputFileType = .mp4
        export.outputURL = exportURL
        
        await export.export()
        if export.status == .completed {
            return exportURL
        } else {
            print(export.outputURL, " erfregt")
            print(export.asset, " thbgvfd")
            print(export.asset.isExportable, " hgf")
            print("exportstatus: \(export.status)")
            print("exporterror: \(export.error)")
            return nil
        }
    }
    
        
    private func performAddVideo(url:String) async -> Bool {
        let movie:AVMutableComposition = await movie()
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
                self.presenter?.movie = movie
                self.presenter?.movieURL = localUrl
                return true
            }
            return false
        } catch let error {
            print(error.localizedDescription, " parformAddVideoparformAddVideo")
            return false
        }
    }
}


//MARK: Setup
fileprivate extension EditorViewModel {
    @MainActor private func movie() -> AVMutableComposition {
        return presenter?.movie ?? .init()
    }
    
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
    
    private func videoSize(assetTrack:AVAssetTrack) -> CGSize {
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        if videoInfo.isPortrait {
            return CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width)
        } else {
            return assetTrack.naturalSize
        }
    }
    
    private func videoLayer(assetTrack:[AVAssetTrack], background:CALayer?, overlayLayer: CALayer?, composition:AVMutableComposition) -> AVMutableVideoComposition? {
        var tracks:[AVMutableCompositionTrack] = []
        assetTrack.forEach({
            if let compositionTrack:AVMutableCompositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) {
                tracks.append(compositionTrack)
                do {
                    try compositionTrack.insertTimeRange(.init(start: .zero, duration: $0.asset!.duration), of: $0, at: .zero)
                } catch {
                }
            }
            
        })
        
        let videoSize = videoSize(assetTrack: assetTrack.first!)
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .init(x: 20, y: 20), size: .init(width: videoSize.width - 40, height: videoSize.height - 40))
        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        if let background {
            outputLayer.addSublayer(background)
        }
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
        var i = 0
        assetTrack.forEach({
            let layerInstruction = compositionLayerInstruction(
                for: tracks[i],
                assetTrack: $0)
            i += 1
            instruction.layerInstructions.append(layerInstruction)
        })
        
        
        return videoComposition
    }
}


//MARK: add layers
fileprivate extension EditorViewModel {
    func add(text: String, to layer: CALayer, videoSize: CGSize) {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold) as Any,
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
            y: videoSize.height * 0.66,
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

fileprivate extension EditorViewModel {
    private func toComposition(asset:AVAsset) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let duration = CMTime(seconds: asset.duration.seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        asset.tracks(withMediaType: .video).forEach( {
            let sourceAudioTrack = $0
            do {
                try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: duration), of: sourceAudioTrack, at: CMTime.zero)
            } catch {
                print(error.localizedDescription)
            }
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
            catch {
                print("errorfwed ")
            }
        }
        
        return composition
    }
}



//MARK: test
fileprivate extension EditorViewModel {
    private func addTestVideos() async -> Bool {
        let urls:[String] = ["1", "2"]
        
        for url in urls {
            let ok = await performAddVideo(url: url)
            if ok {
                if url == urls.last {
                    return true
                }
            } else {
                return false
            }
        }
        return false
    }
    
}
