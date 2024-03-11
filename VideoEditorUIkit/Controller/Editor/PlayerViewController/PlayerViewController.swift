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
    func addTrackPressed()
    func clearDataPressed()
    func reloadUI()
    func playTimeChanged(_ percent:CGFloat)
}

class PlayerViewController: PlayerSuperVC {
    
    fileprivate var preseter:PlayerViewControllerPresenter?
    private var parentVC: EditorViewController? {
        return self.parent as? EditorViewController
    }
    private var addVideoButton:UIButton? {
        view.subviews.first(where: {$0.layer.name == "addButton"}) as? UIButton
    }
    var editingAttachmentView:UIView? {
        view.subviews.first(where: {$0.layer.name == "editingAttachmentView"})
    }
    override var initialAnimation: Bool { return false}

    // MARK: - life-cycle
    override func loadView() {
        super.loadView()
        self.loadUI()
    }
    
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
        playerLayer?.removeFromSuperlayer()
        preseter = nil
    }
    
    //MARK: - setup ui
    func setUI(type:EditorViewType) {
        addVideoButton?.isHidden = type == .editing
    }
    
    // MARK: - IBAction
    func editingAttachmentPressed(_ data:MovieAttachmentProtocol) {
        editingAttachmentView?.removeFromSuperview()
        if data.attachmentType == .text, 
            let textDB = data as? TextAttachmentDB {
            loadEditingView(textDB)
        }
    }
        
    func editorOverlayRemoved() {
        editingAttachmentView?.removeWithAnimation()
    }
    
    override func timeChanged(_ percent: CGFloat) {
        super.timeChanged(percent)
        preseter?.playTimeChanged(percent)
    }
    
    @objc fileprivate func addTrackPressed(_ sender:UIButton) {
        startRefreshing {
            self.pause()
            self.preseter?.addTrackPressed()
        }
    }
    
    @objc fileprivate func deletePressed(_ sender:UIButton) {
        startRefreshing {
            self.pause()
            self.preseter?.clearDataPressed()
        }
    }
    
    @objc fileprivate func reloadUIPressed(_ sender:UIButton) {
        startRefreshing {
            self.pause()
            self.preseter?.reloadUI()
        }
    }
    
    @objc fileprivate func deleteAttachmentPressed(_ sender:UIButton) {
        startRefreshing {
            Task {
                self.parentVC?.viewModel?.editorModel.deleteAttachmentPressed(nil)
            }
        }
    }
}


// MARK: loadUI
fileprivate extension PlayerViewController {
    func loadUI() {
        addMovieButton()
        addDeleteAllButton()
    }
    
    private func addMovieButton() {
        if let _ = addVideoButton {
            return
        }
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(self.addTrackPressed(_:)), for: .touchUpInside)
        button.layer.name = "addButton"
        view.addSubview(button)
        button.addConstaits([
            .bottom:10, .left:10
        ])
    }
    
    private func addDeleteAllButton() {
        
        if let _ = view.subviews.first(where: {$0.layer.name == "deleteButton"}) {
            return
        }
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.layer.name = "deleteButton"
        view.addSubview(stack)
        
        let button = UIButton()
        button.setTitle("deleteAll", for: .normal)
        button.addTarget(self, action: #selector(self.deletePressed(_:)), for: .touchUpInside)
        stack.addArrangedSubview(button)
        
        let clearButton = UIButton()
        clearButton.setTitle("reload all", for: .normal)
        clearButton.addTarget(self, action: #selector(self.reloadUIPressed(_:)), for: .touchUpInside)
        stack.addArrangedSubview(clearButton)
        
        
        let attachmentButton = UIButton()
        attachmentButton.setTitle("rem attch", for: .normal)
        attachmentButton.addTarget(self, action: #selector(self.deleteAttachmentPressed(_:)), for: .touchUpInside)
        attachmentButton.layer.name = "addAttachmentDeleteButton"
        stack.addArrangedSubview(attachmentButton)
        
        stack.addConstaits([
            .top:10, .left:10, .right:10
        ])
    }
    
    private func loadEditingView(_ textDB:TextAttachmentDB) {
        let newView = UILabel()
        newView.layer.name = "editingAttachmentView"
        view.addSubview(newView)
        let model = AttachentVideoLayerModel()
        let layer = model.add(to: newView.layer, videoSize: movie?.tracks.first(where: {$0.naturalSize.width != 0})?.naturalSize ?? .zero, text: textDB)
        newView.addConstaits([.left:0, .right:0, .top:0, .bottom:0])
        newView.layer.addSublayer(layer)
        newView.appeareAnimation()
    }
}


extension PlayerViewController {
    static func configure(_ presenter:PlayerViewControllerPresenter) -> PlayerViewController {
        let vc = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController ?? .init()
        vc.preseter = presenter
        return vc
    }
}
