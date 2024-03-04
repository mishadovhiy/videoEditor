//
//  EditingOvarlayVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

protocol EditorOverlayVCDelegate {
    func addAttachmentPressed(_ attachmentData:AssetAttachmentProtocol?)
    func overlayRemoved()
}

class EditorOverlayVC: UIViewController {

    private var attachmentData:AssetAttachmentProtocol?
    private var addAttachmentPressed:(()->())?
    private var delegate:EditorOverlayVCDelegate?
    
    override func removeFromParent() {
        animateShow(show: false) {
            self.delegate?.overlayRemoved()
            self.delegate = nil
            super.removeFromParent()
        }
    }
    
    deinit {
        removeFromParent()
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        addAttachmentPressed?()
        removeFromParent()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        removeFromParent()
    }
}

fileprivate extension EditorOverlayVC {
    func animateShow(show:Bool, completion:(()->())? = nil) {
        if show {
            view.alpha = 0
            view.layer.zoom(value: 0.7)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = show ? 1 : 0
            self.view.layer.zoom(value: !show ? 1.2 : 1)
        }, completion: { _ in
            completion?()
        })
    }
}

extension EditorOverlayVC {
    static func configure(data:AssetAttachmentProtocol?,
                          delegate:EditorOverlayVCDelegate) -> EditorOverlayVC {
        let vc = UIStoryboard(name: "Reusable", bundle: nil).instantiateViewController(withIdentifier: "EditorOverlayVC") as? EditorOverlayVC ?? .init()
        vc.view.layer.name = String(describing: EditorOverlayVC.self)
        vc.attachmentData = data
        vc.delegate = delegate
        return vc
    }
    
    static func addToParent(_ parent:UIViewController,
                            bottomView:UIView,
                            data:AssetAttachmentProtocol?,
                            delegate:EditorOverlayVCDelegate
    ) {
        let vc = EditorOverlayVC.configure(data: data, delegate: delegate)
        vc.view.alpha = 0
        parent.addChild(child: vc, constaits: [.left:0, .right:0])
        vc.view.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -20).isActive = true
        vc.animateShow(show: true)
    }
}
