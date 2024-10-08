//
//  AttachentVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import UIKit

struct AttachentVideoLayerModel {
    static let textLayerName:String = "CATextLayer"
    
    func add(to layer: CALayer, videoSize: CGSize, data:MovieAttachmentProtocol, isPreview:Bool = false, videoViewSize:CGSize? = nil) -> CALayer? {
        print(videoViewSize, " tgerfwdas ")
        if let text = data as? TextAttachmentDB {
            return self.add(to: layer, videoSize: videoSize, text: text, isPreview: isPreview, videoViewSize:videoViewSize)
        } else if let image = data as? ImageAttachmentDB {
            return self.add(to: layer, videoSize: videoSize, image: image, isPreview: isPreview, videoViewSize:videoViewSize)
        } else {
            return nil
        }
    }
    
    private func add(to layer: CALayer, videoSize: CGSize, image:ImageAttachmentDB, isPreview:Bool = false, videoViewSize:CGSize? = nil) -> CALayer {
        print("addimage: ", image)
        let vidSize:CGSize = isPreview ? .init(width: videoSize.width / 4, height: videoSize.height / 1.2) : videoSize
        let layer = CALayer()
        layer.name = AttachentVideoLayerModel.textLayerName
        let x = (image.position.x * vidSize.width)
        let y = (image.position.y * vidSize.height)
        let itemWidth = (videoSize.width / 2) * image.zoom
        layer.frame = .init(origin: .init(x: x + (itemWidth / 2), y: y + (itemWidth / 2)), size: .init(width: itemWidth, height: itemWidth))
        print("onvidframe ", layer.frame)
        let imageData = image.image != nil ? UIImage(data: image.image!) : nil
        guard let imageData = (imageData ?? UIImage(named: "addImage"))?.withTintColor(image.color, renderingMode: .alwaysTemplate) else {
            layer.backgroundColor = UIColor.red.cgColor
            return layer
        }
        layer.contents = imageData.cgImage
        layer.contentsGravity = .resizeAspect
        layer.borderColor = image.borderColor.cgColor
        layer.borderWidth = image.borderWidth * 10
        layer.masksToBounds = image.borderRadius == 0 ? false : true
        setupLayer(layer: layer, data: image, isPreview: isPreview, videoSize: videoSize, layerSize: videoSize)
        return layer
    }
    
    private func add(to layer: CALayer, videoSize: CGSize, text:TextAttachmentDB, isPreview:Bool = false, videoViewSize:CGSize? = nil) -> CALayer {
        print(videoSize, " addtexttext: ", text)
        let vidSize:CGSize = isPreview ? .init(width: videoSize.width / 4, height: videoSize.height / 1.2) : videoSize
        let font = UIFont.systemFont(ofSize: text.fontSize * (isPreview ? 0.76 : 1), weight: text.fontWeight)
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
        let size = UIFont.systemFont(ofSize: font.pointSize + 8, weight: text.fontWeight).calculate(inWindth:vidSize, attributes: attributes, string: attributedText.string)
       // size.height *= text.zoom
        let x = (text.position.x * vidSize.width)
        let y = (text.position.y * vidSize.height)
        print(vidSize, " textPosition: ", text.position)
        textLayer.frame = .init(origin: .init(x: x - (size.width / 2), y: y - (size.height / 2)), size: .init(width: size.width, height: size.height))
        textLayer.zoom(value: text.zoom)
        setupLayer(layer: textLayer, data: text, isPreview: isPreview, videoSize: vidSize, layerSize: size)
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
