//
//  AttachentVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import UIKit

struct AttachentVideoLayerModel {
    func add(text: String, to layer: CALayer, videoSize: CGSize) -> CALayer {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 100, weight: .bold) as Any,
                .foregroundColor: UIColor.green.cgColor,
                .strokeColor: UIColor.white,
                .strokeWidth: -3
            ])
        
        let textLayer = CATextLayer()
        textLayer.name = "CATextLayer"
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        
        textLayer.frame = .init(origin: .init(x: 0, y: videoSize.height * 0.1), size: .init(width: videoSize.width, height: 150))
        textLayer.displayIfNeeded()
        return textLayer
    }
    
    func add(video: String, to layer: CALayer, videoSize: CGSize) -> CALayer {

        let textLayer = CATextLayer()
        textLayer.name = "CATextLayer"
        textLayer.string = "nbg"
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        
        textLayer.frame = .init(origin: .zero, size: .init(width: videoSize.width, height: 150))
        textLayer.displayIfNeeded()
        return textLayer
    }
}
