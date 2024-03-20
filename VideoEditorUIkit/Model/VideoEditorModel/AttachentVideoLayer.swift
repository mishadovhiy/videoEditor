//
//  AttachentVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import UIKit

struct AttachentVideoLayerModel {
    static let textLayerName:String = "CATextLayer"
    
    func add(to layer: CALayer, videoSize: CGSize, data:MovieAttachmentProtocol, isPreview:Bool = false) -> CALayer? {
        if let text = data as? TextAttachmentDB {
            return self.add(to: layer, videoSize: videoSize, text: text, isPreview: isPreview)
        } else if let image = data as? ImageAttachmentDB {
            return self.add(to: layer, videoSize: videoSize, image: image, isPreview: isPreview)
        } else {
            return nil
        }
    }
    
    private func add(to layer: CALayer, videoSize: CGSize, image:ImageAttachmentDB, isPreview:Bool = false) -> CALayer {
        print("add image: ", image)
        let layer = CALayer()
        layer.name = AttachentVideoLayerModel.textLayerName
        layer.frame = .init(origin: image.position, size: .init(width: (videoSize.width / 2) * image.zoom, height: (videoSize.height / 2) * image.zoom))
        let imageData = image.image != nil ? UIImage(data: image.image!) : nil
        guard let imageData = (imageData ?? UIImage(named: "addImage"))?.withTintColor(image.color, renderingMode: .alwaysTemplate) else {
            layer.backgroundColor = UIColor.red.cgColor
            return layer
        }
        layer.contents = imageData.cgImage
        layer.contentsGravity = .resizeAspect
        setupLayer(layer: layer, data: image, isPreview: isPreview, videoSize: videoSize, layerSize: videoSize)
        return layer
    }
    
    private func add(to layer: CALayer, videoSize: CGSize, text:TextAttachmentDB, isPreview:Bool = false) -> CALayer {
        let font = UIFont.systemFont(ofSize: text.fontSize, weight: text.fontWeight)
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: text.color,
            .strokeColor: text.borderColor,
            .strokeWidth: (text.borderWidth * 10)
        ]
        let attributedText = NSAttributedString(
            string: text.assetName ?? "?",
            attributes: attributes)
        
        let textLayer = CATextLayer()
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.string = attributedText
        textLayer.alignmentMode = text.textAlighment.textLayerAligmentMode
        textLayer.isWrapped = true
        textLayer.foregroundColor = text.color.cgColor
        let size = UIFont.systemFont(ofSize: font.pointSize + 8, weight: text.fontWeight).calculate(inWindth: videoSize.width, attributes: attributes, string: attributedText.string, maxSize: videoSize)
       // size.height *= text.zoom
        textLayer.frame = .init(origin: text.position, size: .init(width: videoSize.width, height: size.height))
        textLayer.zoom(value: text.zoom)
        setupLayer(layer: textLayer, data: text, isPreview: isPreview, videoSize: videoSize, layerSize: size)
        return textLayer
    }
}

fileprivate extension AttachentVideoLayerModel {
    func setupLayer(layer:CALayer, data:MovieAttachmentProtocol, isPreview:Bool, videoSize:CGSize, layerSize:CGSize? = nil) {
        
        layer.backgroundColor = UIColor.clear.cgColor
        if isPreview {
            layer.borderColor = UIColor.orange.withAlphaComponent(0.6).cgColor
            layer.borderWidth = 0.5
            layer.cornerRadius = 3
        }
        layer.borderColor = data.borderColor.cgColor
        layer.borderWidth = data.borderWidth * 10
        layer.masksToBounds = data.borderRadius == 0 ? false : true
        layer.cornerRadius = data.borderRadius * 10
        layer.backgroundColor = data.backgroundColor.cgColor
        layer.opacity = Float(data.opacity)
        layer.shadowColor = data.shadows.color.cgColor
        layer.shadowOpacity = Float(data.shadows.opasity * 10)
        layer.shadowRadius = data.shadows.radius
        print(videoSize, " hgftyguhkjn")
        layer.name = AttachentVideoLayerModel.textLayerName
        layer.displayIfNeeded()
    }
}
