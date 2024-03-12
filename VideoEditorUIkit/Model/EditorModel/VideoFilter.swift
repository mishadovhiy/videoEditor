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

            let output = filter?.outputImage?.cropped(to: request.sourceImage.extent)
            request.finish(with: output ?? .empty(), context: nil)
            print(request.compositionTime, " applying filter")
            if request.compositionTime == composition.duration {
                print("filter apllied")
                completion((output?.url))
            }
        }
        return videoComposition
    }
}
