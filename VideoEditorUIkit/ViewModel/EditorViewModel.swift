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
    var videoTrack: AVMutableCompositionTrack?
    var audioTrack: AVMutableCompositionTrack?
    var model:TrackAppearenceModel? = TrackAppearenceModel(count: [.init(width: 10, title: "aa")])
    
    init(presenter:ViewModelPresenter) {
        self.presenter = presenter
        self.videoTrack = presenter.movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        self.audioTrack = presenter.movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    }
    
    deinit {
        presenter = nil
        videoTrack = nil
        audioTrack = nil
        model = nil
    }
    
    func addVideo() {
        Task {
            if await addTestVideos() {
                if await addText(toVideoURL: self.presenter!.movieURL) {
                    await presenter?.videoAdded()
                } else {
                    await presenter?.errorAddingVideo()
                }
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
    
    @MainActor private func movie() -> AVMutableComposition {
        return presenter?.movie ?? .init()
    }
    
    @MainActor private func appendToMovieObzerver(_ newValue:TrackAppearence) {
        self.model?.movieData.append(newValue)
    }
    
    
    private func videoLayer(assetTrack:AVAssetTrack, background:CALayer?, overlayLayer: CALayer?, composition:AVMutableComposition) -> AVMutableVideoComposition? {
        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return nil
        }
        do {
            try compositionTrack.insertTimeRange(.init(start: .zero, duration: assetTrack.asset!.duration), of: assetTrack, at: .zero)
        } catch {
            return nil
        }
        let videoSize = videoSize(assetTrack: assetTrack)
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
        let layerInstruction = compositionLayerInstruction(
            for: compositionTrack,
            assetTrack: assetTrack)
        instruction.layerInstructions = [layerInstruction]
        
        return videoComposition
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
    
    
    
    func addText(toVideoURL:URL?) async -> Bool {
        let asset:AVAsset
        if let toVideoURL {
            asset = AVAsset(url: toVideoURL)
            print("fdds url")
        } else if let assets = self.asset {
            asset = assets
            print("assesss")
        } else {
            return false
        }
        
        print(asset.tracks.reduce(0, { partialResult, data in
            return partialResult + (data.asset?.duration.seconds ?? 0)
        }), "duratiorndsds ")
        let composition = AVMutableComposition()
        
        do {
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error)
            return false
        }
        guard let assetTrack = asset.tracks(withMediaType: .video).first else {
            return false
        }
        let videoSize = videoSize(assetTrack: assetTrack)
        
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
        if let localUrl = await export(asset: asset, videoComposition: videoComposition) {
            self.presenter?.movieURL = localUrl
            return true
        } else {
            return false
        }
        
    }
    
    
    private func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?) async -> URL? {
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            
            let sourceAudioTrack = asset.tracks(withMediaType: AVMediaType.video).first!
            do {
                let durationInSec = asset.duration.seconds
                let duration = CMTime(seconds: durationInSec, preferredTimescale: 1)
                try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: duration), of: sourceAudioTrack, at: CMTime.zero)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        
        guard let export = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            // onComplete(nil)
            return nil
        }
        
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mp4")
        if let videoComposition {
            export.videoComposition = videoComposition
        } else {
            export.shouldOptimizeForNetworkUse = true
            export.timeRange = .init(start: .zero, duration: asset.duration)
        }
        export.outputFileType = .mp4
        export.outputURL = exportURL
        
        // self.presenter?.movieURL = exportURL
        
        await export.export()
        if export.status == .completed {
            // fatalError("okkk")
            print("fsdasfd ", exportURL)
            //   VideoEditor.url = exportURL
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
    
    func prepare(asset:AVAsset) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        
        do {
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error)
            return nil
        }

        return composition
    }
    
    var asset:AVAsset?
    private func performAddVideo(url:String) async -> Bool {
        let movie = await movie()
        guard let url = Bundle.main.url(forResource: url, withExtension: "mov") else {
            fatalError()
        }
        let newMovie = AVURLAsset(url: url)
        do {
            let duration = try await newMovie.load(.duration)
            let range = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            print("duration ", duration.seconds)
//            movie.addMutableTrack(withMediaType: .video, preferredTrackID:  Int32(kCMPersistentTrackID_Invalid))
            try movie.insertTimeRange(range, of: newMovie, at: .zero)
            
            await self.appendToMovieObzerver(.init(width: duration.seconds, title: "\(duration.seconds)"))
            print(movie.tracks.first!.asset!.duration, " rtegrfsed")
            let ass = movie.tracks.first

            print(movie, " rhtgef")

            if let localUrl = await export(asset: movie, videoComposition: nil) {
                self.presenter?.movieURL = localUrl
                self.asset = movie//movie
               //  fatalError()
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
      //  return await performAddVideo(url: "1")
        return false
    }
    
    
    
}
