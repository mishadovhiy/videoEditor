//
//  AssetRawView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

class AssetRawView:UIView {
    private var headerView:UIView? {
        self.subviews.first(where: {$0.layer.name == "Header" })
    }
    private var titleLabel:UILabel? {
        headerView?.subviews.first(where: {$0 is UILabel}) as? UILabel
    }
    private var data:MovieAttachmentProtocol?
    private var editRowPressed:((_ row: MovieAttachmentProtocol?)->())?
    
    func updateView(data:MovieAttachmentProtocol?,
                    updateConstraints:Bool = true,
                    editRowPressed:@escaping(_ row: MovieAttachmentProtocol?)->()) {
        self.data = data
        self.editRowPressed = editRowPressed
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
    
    deinit {
        data = nil
    }
    
    @objc private func editRowPressed(_ sender:UITapGestureRecognizer) {
        editRowPressed?(data)
    }
}

extension AssetRawView {
    static func create(superView:UIView?, 
                       data:MovieAttachmentProtocol?,
                       vcSuperView:UIView,
                       editRowPressed:@escaping(_ row: MovieAttachmentProtocol?)->() ) {
        let new = AssetRawView()
        new.backgroundColor = data?.color
        new.layer.name = data?.id.uuidString
        superView?.addSubview(new)
        new.addConstaits([.left:data?.inMovieStart ?? 10, .top:0, .bottom:0, .width:data?.duration ?? 10])
        new.createHeader(vcSuperView: vcSuperView)
        new.updateView(data: data, updateConstraints: false, editRowPressed: editRowPressed)
    }
    
    private func createHeader(vcSuperView:UIView) {
        let headerView = UIView()
        headerView.layer.name = "Header"
        self.addSubview(headerView)
        headerView.addConstaits([.left:0, .top:0, .bottom:0, .right:0])
        headerView.leadingAnchor.constraint(greaterThanOrEqualTo: vcSuperView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        let label:UILabel = .init()
        label.adjustsFontSizeToFitWidth = true
        headerView.addSubview(label)
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0])
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editRowPressed(_:))))
    }
}
