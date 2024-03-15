//
//  UIImage.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit
import CoreMedia

extension UIImage {
    convenience init?(sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func applyFilter(filterName: String) -> UIImage? {
        if filterName == "none" {
            return nil
        }
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        guard let filter = CIFilter(name: filterName) else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputCIImage = filter.outputImage else {
            return nil
        }
        
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        let filteredImage = UIImage(cgImage: cgImage)
        
        return filteredImage
    }
}
