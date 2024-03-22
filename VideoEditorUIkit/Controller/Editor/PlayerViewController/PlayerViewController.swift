//
//  PlayerViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import UIKit
import AVFoundation
import Photos

protocol PlayerViewControllerPresenter {
    func clearDataPressed()
    func reloadUI()
    func playTimeChanged(_ percent:CGFloat)
}

class PlayerViewController: PlayerSuperVC {
    
    fileprivate var preseter:PlayerViewControllerPresenter?
    var parentVC: EditorViewController? {
        return self.parent as? EditorViewController
    }
    var editingAttachmentView:PlayerEditingAttachmentView? {
        view.subviews.first(where: {$0.layer.name == PlayerEditingAttachmentView.layerName}) as? PlayerEditingAttachmentView
    }
    override var initialAnimation: Bool { return false}

    // MARK: - life-cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.subviews.forEach {
            $0.layer.zPosition = 999
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        preseter = nil
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        pause()
        preseter = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editingAttachmentView?.dataUpdated(force: true)
    }
    
    //MARK: - setup ui
    func setUI(type:EditorViewType) {  }
    
    private func overlayEdited(_ newData:AssetAttachmentProtocol?) {
        self.parentVC?.playerChangedAttachment(newData)
    }
    
    // MARK: - IBAction
    func editingAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        editingAttachmentView?.removeFromSuperview()
        if let textDB = data as? MovieAttachmentProtocol {
            loadEditingView(textDB)
        }
    }
        
    func editorOverlayRemoved() {
        editingAttachmentView?.removeWithAnimation()
    }
    
    override func playerTimeChanged(_ percent: CGFloat) {
        super.playerTimeChanged(percent)
        if isPlaying {
            preseter?.playTimeChanged(percent)
        } else if percent == 0 {
            preseter?.playTimeChanged(percent)
        }
    }
}


// MARK: loadUI
fileprivate extension PlayerViewController {
    private func loadEditingView(_ textDB:MovieAttachmentProtocol) {
        let newView = PlayerEditingAttachmentView.configure(data: textDB, dataChanged: overlayEdited(_:), videoSize: movie?.tracks.first?.naturalSize ?? VideoEditorModel.renderSize)
        view.addSubview(newView)
    }
}


extension PlayerViewController {
    static func configure(_ presenter:PlayerViewControllerPresenter?) -> PlayerViewController {
        let vc = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController ?? .init()
        vc.preseter = presenter
        return vc
    }
}
