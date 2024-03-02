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
    
    func exportVideo(videoComposition: AVVideoComposition?) async -> URL? {
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mp4")
        if let videoComposition {
            self.videoComposition = videoComposition
        }
        self.metadata = []
        self.shouldOptimizeForNetworkUse = false
        self.timeRange = .init(start: .zero, duration: asset.duration)
        self.outputFileType = .mp4
        self.outputURL = exportURL
        
        await self.export()
        if self.status == .completed {
            return exportURL
        } else {
            print("exporterror: \(self.error?.localizedDescription ?? "")")
            print(status.rawValue, " tyhrgtvgr")
            return self.status == .failed ? nil : exportURL
        }
    }
}
