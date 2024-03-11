//
//  VideoFilterComposition.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 08.03.2024.
//

import Foundation
import AVFoundation
import CoreImage

struct VideoFilter {
    
    typealias filterCompletion = (URL?)
    
    static func addFilter(composition:AVMutableComposition,
                   completion:@escaping(filterCompletion) -> ()) -> AVMutableVideoComposition {
        let filter = CIFilter(name: "CIColorInvert")
        let videoComposition = AVMutableVideoComposition(asset: composition) { request in
            let source = request.sourceImage.clampedToExtent()
            filter?.setValue(source, forKey: kCIInputImageKey)
                let seconds = CMTimeGetSeconds(request.compositionTime)
            filter?.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)

            let output = filter?.outputImage?.cropped(to: request.sourceImage.extent)
            request.finish(with: output ?? .empty(), context: nil)
            completion((output?.url))
        }
        return videoComposition
    }
}
