//
//  AVAsset.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import AVFoundation
import UIKit

extension AVAsset {
    func preview(time: CMTime) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        var actualTime: CMTime = .zero
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
            let image = UIImage(cgImage: imageRef)
            return image
        } catch let error as NSError {
            print("\(error.description). error time: \(actualTime)")
            return nil
        }
    }
    
    func duration(isAsync:Bool = true) async -> CMTime {
        if !isAsync {
            return self.duration
        }
        do {
            if #available(iOS 15, *) {
                return try await load(.duration)
            } else {
                return self.duration
            }
        } catch {
            return .invalid
        }
    }
}
