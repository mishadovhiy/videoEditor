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
    
    func exportVideo(videoComposition: AVMutableVideoComposition?, isVideoAdded:Bool = false) async -> URL? {
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
            //        let metadataItem:AVMutableMetadataItem = .init()
            //        metadataItem.key = AVMetadataKey.commonKeyTitle as any NSCopying & NSObjectProtocol
            //        metadataItem.keySpace = .common
            //        metadataItem.value = "My Custom Metadata Value" as NSString
            //        self.metadata = [metadataItem]
        } else if let videoComposition {
            print(videoComposition.renderSize, " error adding videoComposition")
        }
        self.shouldOptimizeForNetworkUse = false
        self.timeRange = await .init(start: .zero, duration: asset.duration())
        self.outputFileType = .mov
        self.outputURL = exportURL
        
        await self.export()
        if self.status == .completed {
            return exportURL
        } else {
            print("exporterror: \(self.error?.localizedDescription ?? "")")
            print(status.rawValue, " status ")
            return self.status == .failed ? nil : exportURL
        }
    }
}
