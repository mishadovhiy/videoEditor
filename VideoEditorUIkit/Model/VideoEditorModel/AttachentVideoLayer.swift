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
        textLayer.alignmentMode = text.textAlighment.textLayerAligmentMode
        textLayer.isWrapped = true
        textLayer.foregroundColor = text.color.cgColor
        textLayer.shadowColor = text.shadows.color.cgColor
        textLayer.shadowOpacity = Float(text.shadows.opasity)
        textLayer.shadowRadius = text.shadows.radius
        var size = font.calculate(inWindth: videoSize.width, attributes: attributes, string: attributedText.string, maxSize: videoSize)
        size.height *= text.zoom
        setupLayer(layer: textLayer, data: text, isPreview: isPreview, videoSize: videoSize, layerSize: size)
        
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

extension AttachentVideoLayerModel {
    func setupLayer(layer:CALayer, data:MovieAttachmentProtocol, isPreview:Bool, videoSize:CGSize, layerSize:CGSize? = nil) {
        layer.zoom(value: data.zoom)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.backgroundColor = UIColor.clear.cgColor
        if isPreview {
            layer.borderColor = UIColor.orange.withAlphaComponent(0.6).cgColor
            layer.borderWidth = 0.5
            layer.cornerRadius = 3
        }
        
        print(videoSize, " hgftyguhkjn")
        
        layer.frame = .init(origin: data.position, size: .init(width: videoSize.width, height: layerSize?.height ?? videoSize.height))
        layer.displayIfNeeded()
    }
}
