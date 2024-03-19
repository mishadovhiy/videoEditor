//
//  PlayerEditingAttachmentView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 13.03.2024.
//

import UIKit

class PlayerEditingAttachmentView: UIView {
    
    typealias DataChanged = (_ newData:MovieAttachmentProtocol?)->()
    static let layerName:String = "editingAttachmentView"
    
    private var attachmentLayer:CALayer? {
        return layer.sublayers?.first(where:{
            return $0.name == AttachentVideoLayerModel.textLayerName
        })
    }
    
    var data:MovieAttachmentProtocol? {
        didSet { dataUpdated() }
    }
    var dataChanged:DataChanged?
    var videoSize:CGSize?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            loadUI()
        }
    }
    
    func dataUpdated(force:Bool = false) {
        if self.superview == nil { return }
        let model = AttachentVideoLayerModel()
        if let text = data {
            if !force {
                layer.animationTransition(0.17)
            }
            layer.sublayers?.forEach({
                if $0.name == AttachentVideoLayerModel.textLayerName {
                    $0.removeFromSuperlayer()
                }
            })
            if let newLayer = model.add(to: layer, videoSize: videoSize ?? .zero, data: text, isPreview: true) {
                layer.addSublayer(newLayer)
            }
            if !force {
                dataChanged?(text)
            }
        } else {
            print("error unparcing data ", data)
        }
    }
    
    @objc private func panGesture(_ sender:UIPanGestureRecognizer) {
        let position = sender.translation(in: self)
        sender.setTranslation(.zero, in: self)
        let currentPosition = attachmentLayer?.frame ?? .zero
        attachmentLayer?.frame.origin = .init(x: currentPosition.origin.x + position.x, y: currentPosition.minY + position.y)
        if sender.state.isEnded {
            data?.position = attachmentLayer?.frame.origin ?? .zero
        }
    }
    
    @objc private func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let attachmentLayer, !sender.state.isEnded else {
            return
        }
        let currentScale = attachmentLayer.frame.size.width / attachmentLayer.bounds.size.width
        let newScale = currentScale*sender.scale
        attachmentLayer.zoom(value: newScale)
        if let _ = data as? TextAttachmentDB {
            sender.scale = 1
        } else {
            sender.scale = newScale
        }
        data?.zoom = newScale
    }
}


// MARK: - loadUI
fileprivate extension PlayerEditingAttachmentView {
    func loadUI() {
        layer.name = PlayerEditingAttachmentView.layerName
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:))))
        addConstaits([.left:0, .right:0, .top:0, .bottom:0])
        dataUpdated()
        appeareAnimation()
    }
}

extension PlayerEditingAttachmentView {
    static func configure(data:MovieAttachmentProtocol, dataChanged:@escaping DataChanged, videoSize:CGSize) -> PlayerEditingAttachmentView {
        let view = PlayerEditingAttachmentView.init()
        view.videoSize = videoSize
        view.dataChanged = dataChanged
        view.data = data
        view.alpha = 0
        return view
    }
}
