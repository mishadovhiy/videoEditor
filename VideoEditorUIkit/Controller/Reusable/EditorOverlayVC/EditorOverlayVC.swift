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

    var attachmentData:AssetAttachmentProtocol?
    private var delegate:EditorOverlayVCDelegate?
    
    override func removeFromParent() {
        view.endEditing(true)
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
        delegate?.addAttachmentPressed(attachmentData)
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
        vc.attachmentData = data ?? TextAttachmentDB.init(dict: [:])
        vc.delegate = delegate
        return vc
    }
    
    static func addToParent(_ parent:UIViewController,
                            bottomView:UIView,
                            data:AssetAttachmentProtocol?,
                            delegate:EditorOverlayVCDelegate
    ) {
        print(parent.classForCoder.description(), " fcgvyhugcvgyu")
        print(parent, " jkhjgy")

        let vc = EditorOverlayVC.configure(data: data, delegate: delegate)
        vc.view.alpha = 0
        parent.addChild(child: vc, constaits: [.left:0, .right:0, .height:75])
        vc.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor, constant: -2).isActive = true
        vc.animateShow(show: true)
    }
}
