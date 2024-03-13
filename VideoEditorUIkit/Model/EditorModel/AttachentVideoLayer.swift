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
        let attributedText = NSAttributedString(
            string: text.assetName ?? "?",
            attributes: [
                .font: UIFont.systemFont(ofSize: text.fontSize, weight: text.fontWeight),
                .foregroundColor: UIColor.green.cgColor,
                .strokeColor: UIColor.white,
//                .foregroundColor: text.color,
//                .strokeColor: text.borderColor,
                .strokeWidth: 1
            ])
        
        let textLayer = CATextLayer()
        textLayer.name = AttachentVideoLayerModel.textLayerName
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = isPreview ? UIColor.red.withAlphaComponent(0.2).cgColor : UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        print(videoSize.width, " grerfewdws")
        textLayer.frame = .init(origin: text.position, size: .init(width: videoSize.width, height: 500))
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
