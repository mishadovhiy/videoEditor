//
//  AssetAttachmentView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit
protocol AssetAttachmentViewDelegate {
    func attachmentSelected(_ data:MovieAttachmentProtocol?, view:UIView?)
    func attachmentPanChanged(view:AssetRawView?)
    var vc:UIViewController { get }
}

class StackAssetAttachmentView:UIView {
    var mediaType:InstuctionAttachmentType?
    private var data:[MovieAttachmentProtocol] = []
    private var delegate:AssetAttachmentViewDelegate?
    var attachmentType:InstuctionAttachmentType? {
        return data.first?.attachmentType ?? mediaType
    }
    
    private var layerStack:UIStackView? {
        return self.subviews.first(where: {$0 is UIStackView}) as? UIStackView
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                self.loadUI()
            })
        }
    }

    override func removeFromSuperview() {
        layerStack?.arrangedSubviews.forEach({
            $0.subviews.forEach {
                $0.removeFromSuperview()
            }
            $0.removeFromSuperview()
        })
        super.removeFromSuperview()
        delegate = nil
    }
    
    func setEmptyViewHidden(_ hidden:Bool, view:UIView, completion:(()->())? = nil) {
        view.isUserInteractionEnabled = !hidden
        let animation = UIViewPropertyAnimator(duration: hidden ? 0.5 : 0.25, curve: .easeInOut) {
            view.alpha = hidden ? 0 : 1
            view.layer.zoom(value: hidden ? 0.7 : 1)
        }
        animation.addCompletion { _ in
            completion?()
        }
        animation.startAnimation()
    }
    
    func setSelected(_ selected:Bool) {
        layer.animationTransition(0.2)
        layer.borderColor = selected ? UIColor.orange.cgColor : UIColor.clear.cgColor
        layer.borderWidth = selected ? 3 : 0
        if !selected,
           let view = layerStack?.arrangedSubviews.first(where: {
               $0.subviews.contains(where: {$0.layer.name == "isEmptyView"})})?.subviews.first(where: {
                   $0.layer.name == "isEmptyView"
               })
        {
            setEmptyViewHidden(true, view: view) {
                view.removeFromSuperview()
            }
        }
    }
    
    func deselectAll() {
        setSelected(false)
        layerStack?.arrangedSubviews.forEach( {
            $0.subviews.forEach {
                if let rowView = $0 as? AssetRawView {
                    rowView.setSelected(false)
                }
            }
        })
    }
    
    // MARK: @IBAction
    private func editRowPressed(_ data:MovieAttachmentProtocol?, view:AssetRawView? = nil) {
        delegate?.attachmentSelected(data, view: view ?? self)
    }
    
    private func assetChangePanEnded(_ view:AssetRawView?) {
        delegate?.attachmentPanChanged(view:view)
    }
    
    @objc private func emptyRowPressed(_ sender:UITapGestureRecognizer) {
        var newData = TextAttachmentDB.demo
        newData.inMovieStart = 0.2
        newData.duration = 0.2
        if let superView = (delegate as? EditorParametersViewController)?.scrollView {
            let scroll = superView.contentOffset.x / superView.contentSize.width
            newData.inMovieStart = scroll >= 1 ? 1 : (scroll <= 0 ? 0 : scroll)
        }
        self.setSelected(true)
        addRowView(data: newData, isEmpty: true) { view in
            view.layer.name = "isEmptyView"
            view.alpha = 0
            view.layer.zoom(value: 0.7)
            self.editRowPressed(newData, view: view)
            self.setEmptyViewHidden(false, view: view)
            view.setSelected(true)
        }
    }
}

extension StackAssetAttachmentView {
    public func updateView(_ data:[MovieAttachmentProtocol]? = nil) {
        updateSuperViews()
        if let data {
            self.data = data
        }
        guard let stack = self.layerStack else {
            return
        }
        data?.forEach({
            self.addRowView(data: $0)
        })
        if data?.isEmpty ?? true {
            
        }
    }
    
    private func addRowView(data:MovieAttachmentProtocol, isEmpty:Bool = false, created:((_ view:AssetRawView)->())? = nil) {
        let layer = isEmpty ? 0 : self.data.layerNumber(item: data)
        if let layer,
            let toView = layerStack?.arrangedSubviews[layer] {
            AssetRawView.create(superView: toView, data: data, vcSuperView: delegate!.vc.view, editRowPressed: editRowPressed(_:view:), panEnded: assetChangePanEnded(_:), created:created)

            toView.isHidden = false
        } else {
            print("freadwergthf ", layer)
        }
        
    }
}


fileprivate extension StackAssetAttachmentView {
    func loadUI() {
        if layerStack != nil {
            self.updateView(self.data)
            return
        }
        let layerStack:UIStackView = .init()
        layerStack.axis = .vertical
        layerStack.distribution = .fillEqually
        addSubview(layerStack)
        for i in 0..<5 {
            let view = UIView()
            view.isHidden = true
            view.tag = i
            layerStack.addArrangedSubview(view)
        }
        layerStack.addConstaits([.left:0, .right:0, .top:0, .bottom:0])
        self.updateView(self.data)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyRowPressed(_:))))
    }
    
    private func updateSuperViews() {
        layerStack?.arrangedSubviews.forEach({
            $0.subviews.forEach {
                $0.removeFromSuperview()
            }
        })
    }
}


extension StackAssetAttachmentView {
    static func create(_ data:[MovieAttachmentProtocol], type:InstuctionAttachmentType, delegate:AssetAttachmentViewDelegate?, to view:UIStackView) {
        let new = StackAssetAttachmentView.init(frame: .zero)
        new.mediaType = type
        new.backgroundColor = .white.withAlphaComponent(0.1)
        new.data = data
        new.delegate = delegate
    //    new.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        view.addArrangedSubview(new)
    }
}
