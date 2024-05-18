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
        didSet { 
            print("attachmenmtDidSetdsa")
            dataUpdated() }
    }
    var dataChanged:DataChanged?
    var videoSize:CGSize? {
        return VideoEditorModel.renderSize
    }
    
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
    lazy var attachmentAnimation = AnimateVideoLayer()
    private var animating:Bool = false
    
    func playerTimeChanged(_ percent:CGFloat) {
        guard let data else {
            return
        }
        let to = data.time.start + data.time.duration
        let hide = data.time.start > percent || (to < percent && percent > data.time.start)
        let change = self.alpha != (hide ? 0 : 1)
        if change && !animating {
            animating = true
            self.attachmentAnimation.appearenceAnimation(data, newLayer: layer, show: !hide)
            Timer.scheduledTimer(withTimeInterval: data.animations.appeareAnimation.duration, repeats: false) { _ in
                self.alpha = hide ? 0 : 1
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(20), execute: {
                    self.animating = false
                })
            }
          //  self.alpha = hide ? 0 : 1
        }
    }
    
    @objc private func panGesture(_ sender:UIPanGestureRecognizer) {
        let position = sender.translation(in: self)
        let resultes:CGPoint = .init(x: position.x / (self.superview?.frame.width ?? 0), y: position.y / (self.superview?.frame.height ?? 0))
        let value = data?.position ?? .zero
        data?.position = .init(x: resultes.x + value.x, y: value.y + resultes.y)
        sender.setTranslation(.zero, in: self)
    }
    
    @objc private func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let attachmentLayer, !sender.state.isEnded else {
            return
        }
        let currentScale = attachmentLayer.frame.size.width / attachmentLayer.bounds.size.width
        let newScale = currentScale*sender.scale
        if let _ = data as? TextAttachmentDB {
            sender.scale = 1
        } else {
            sender.scale = newScale
        }
        data?.zoom = newScale
        if sender.state.isEnded {
            dataUpdated()
        }
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
      //  view.videoSize = videoSize
        view.dataChanged = dataChanged
        view.data = data
        view.alpha = 0
        return view
    }
}
