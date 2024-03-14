//
//  AttachentVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import UIKit

struct AttachentVideoLayerModel {
    static let textLayerName:String = "CATextLayer"
    
    func add(to layer: CALayer, videoSize: CGSize, text:TextAttachmentDB, isPreview:Bool = false) -> CALayer {
        let font = UIFont.systemFont(ofSize: text.fontSize, weight: text.fontWeight)
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: text.color,
            .strokeColor: text.borderColor,
            .strokeWidth: text.borderWidth
        ]
        let attributedText = NSAttributedString(
            string: text.assetName ?? "?",
            attributes: attributes)
        
        let textLayer = CATextLayer()
        textLayer.name = AttachentVideoLayerModel.textLayerName
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        if isPreview {
            textLayer.borderColor = UIColor.orange.withAlphaComponent(0.6).cgColor
            textLayer.borderWidth = 0.5
            textLayer.cornerRadius = 3
        }
        textLayer.alignmentMode = .center
        textLayer.isWrapped = true
        let size = font.calculate(inWindth: videoSize.width, attributes: attributes, string: attributedText.string, maxSize: videoSize)
        textLayer.frame = .init(origin: text.position, size: .init(width: videoSize.width, height: size.height))
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
