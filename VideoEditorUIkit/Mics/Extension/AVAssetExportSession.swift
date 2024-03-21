//
//  AVAssetExportSession.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation

extension AVAssetExportSession {
    
    convenience init?(composition:AVMutableComposition) {
        self.init(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    }
    
    func exportVideo(videoComposition: AVMutableVideoComposition?, isVideoAdded:Bool = false, volume:Float? = nil) async -> Response {
        let videoName = UUID().uuidString
        print("newvideoname ", videoName)
        var directory = NSTemporaryDirectory()
        let exportURL = URL(fileURLWithPath: directory)
            .appendingPathComponent(videoName)
            .appendingPathExtension("mov")
        if let videoComposition,
           (videoComposition.renderSize.width > 0 && videoComposition.renderSize.height > 0)
        {
            print(videoComposition.renderSize, " reder size")
            self.videoComposition = videoComposition
        } else if let videoComposition {
            print(videoComposition.renderSize, " error adding videoComposition")
        }
        self.shouldOptimizeForNetworkUse = true
        self.timeRange = await .init(start: .zero, duration: asset.duration())
        self.outputFileType = .mov
        self.outputURL = exportURL
        if let volume {
            let mixParams = AVMutableAudioMixInputParameters()
            mixParams.setVolume(volume, at: .zero)
            
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = [mixParams]
            self.audioMix = audioMix
        }
        await self.export()
        if self.status == .completed {
            return .success(Response.VideoExport.init(url: exportURL))
        } else if self.status == .failed {
            print("exporterror: \(self.error?.localizedDescription ?? "")")
            print(status.rawValue, " status ")
            
            return .error(self.error?.localizedDescription)
        } else {
            return .success(Response.VideoExport(url: exportURL))
        }
    }
}
