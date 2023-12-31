//
//  AssetRawView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

class AssetRawView:UIView {
    var headerView:UIView? {
        self.subviews.first(where: {$0.layer.name == "Header" })
    }
    var titleLabel:UILabel? {
        headerView?.subviews.first(where: {$0 is UILabel}) as? UILabel
    }
    var data:MovieAttachmentProtocol?
    
    func updateView(data:MovieAttachmentProtocol?, updateConstraints:Bool = true) {
        print("AssetRawViewAssetRawViewAssetRawView")
        titleLabel?.text = data?.assetName ?? data?.defaultName
        self.backgroundColor = data?.color
        
        if updateConstraints {
            superview!.constraints.first(where: {$0.firstAttribute == .left})!.constant = data!.inMovieStart
            superview!.constraints.first(where: {$0.firstAttribute == .width})!.constant = data!.duration
            superview?.layoutIfNeeded()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        data = nil
    }
}

extension AssetRawView {
    static func create(superView:UIView?, data:MovieAttachmentProtocol?, vcSuperView:UIView) {
        let new = AssetRawView()
        new.backgroundColor = data?.color
        new.layer.name = data?.id.uuidString
        superView?.addSubview(new)
        new.addConstaits([.left:data?.inMovieStart ?? 10, .top:0, .bottom:0, .width:data?.duration ?? 10], superView: superView!)
        new.createHeader(vcSuperView: vcSuperView)
        new.updateView(data: data, updateConstraints: false)
    }
    
    private func createHeader(vcSuperView:UIView) {
        let headerView = UIView()
        headerView.layer.name = "Header"
        self.addSubview(headerView)
        headerView.addConstaits([.left:10, .top:0, .bottom:0, .right:0], superView: self)
        headerView.leadingAnchor.constraint(greaterThanOrEqualTo: vcSuperView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        let label:UILabel = .init()
        label.adjustsFontSizeToFitWidth = true
        headerView.addSubview(label)
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superView: headerView)
    }
}
