//
//  AssetAttachmentView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

class AssetAttachmentView:UIView {
    var data:[MovieAttachmentProtocol] = []
    var delegate:AssetAttachmentViewDelegate?
    
    var layerStack:UIStackView? {
        return self.subviews.first(where: {$0 is UIStackView}) as? UIStackView
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            loadUI()
        }
    }

}

extension AssetAttachmentView {
    public func updateView(_ data:[MovieAttachmentProtocol]? = nil) {
        if let data {
            self.data = data
        }
        guard let stack = layerStack,
                let firstView = stack.arrangedSubviews.first else {
            return
        }
        self.data.forEach({
            print("egrfsed ", $0)
            let id = $0.id.uuidString
            if let view = stack.arrangedSubviews.first(where: {$0.subviews.first(where: {$0.layer.name == id}) != nil}) {
                view.superview?.isHidden = false
                
                (view as! AssetRawView).updateView(data: $0)
                //check layer
            } else {
                let toView = stack.arrangedSubviews.first
                AssetRawView.create(superView: toView, data: $0, vcSuperView: delegate!.vc.view)
                toView?.isHidden = false
            }
            
        })
    }
}


fileprivate extension AssetAttachmentView {
    func loadUI() {
        if layerStack != nil {
            return
        }
        let layerStack:UIStackView = .init()
        layerStack.axis = .vertical
        layerStack.distribution = .fillEqually
        addSubview(layerStack)
        layerStack.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superView: self)
        for i in 0..<5 {
            let view = UIView()
            view.isHidden = true
            layerStack.addArrangedSubview(view)
        }
        self.updateView()
    }
    
}


extension AssetAttachmentView {
    static func create(_ data:[MovieAttachmentProtocol], delegate:AssetAttachmentViewDelegate?, to view:UIStackView) {
        print("tgerfwedw")
        let new = AssetAttachmentView.init(frame: .zero)
        new.backgroundColor = .orange
        new.data = data
        new.delegate = delegate
        view.addArrangedSubview(new)
        new.addConstaits([.height:50], superView: view)
    }
}
