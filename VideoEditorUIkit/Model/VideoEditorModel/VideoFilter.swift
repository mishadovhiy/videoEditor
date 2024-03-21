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
    typealias filterResult = (composition:AVMutableVideoComposition?,
                              error: NSError?
    )
    fileprivate static var timeHolder:CMTime?
    
    fileprivate static func timeChanged(time:CMTime?, changed:@escaping(Bool)->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30), execute: {
            changed(self.timeHolder == time)
        })
    }
    
    static func addFilter(composition:AVMutableComposition,
                          completion:@escaping(filterCompletion) -> ()) -> filterResult {
        let filterDB = DB.db.movieParameters.editingMovie?.filter ?? .none
        if filterDB == .none {
            return (nil, nil)
        }
        let filter = CIFilter(type: filterDB)
        let total = prepareTime(total: composition.duration)
        print(total, " add filter: total composition time")
        var completed = false
        let videoComposition = AVMutableVideoComposition(asset: composition) { request in
            if completed {
                print("filtering after complet called")
            }
            let source = request.sourceImage.clampedToExtent()
            filter?.setValue(source, forKey: kCIInputImageKey)
            
            let output = filter?.outputImage?.cropped(to: request.sourceImage.extent)
            request.finish(with: output ?? .empty(), context: nil)
            print(request.compositionTime, " applying filter of: ", composition.duration)
            timeHolder = request.compositionTime
            if request.compositionTime >= total && !completed {
                completed = true
                print("filter apllied")
                timeHolder = nil
                completion((output?.url))
            } else if !completed {
                timeChanged(time: request.compositionTime) {
                    if $0 {
                        completed = true
                        self.timeHolder = nil
                        completion((output?.url))
                    }
                }
            }
        }
        return (videoComposition, nil)
    }
    
    private static func prepareTime(total:CMTime) -> CMTime {
        let percent = (0.19 * total.seconds) / 100
        return total - .init(seconds: percent, preferredTimescale: total.timescale)
    }
}
