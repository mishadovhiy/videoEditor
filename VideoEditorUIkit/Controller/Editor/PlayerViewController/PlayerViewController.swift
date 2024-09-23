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
    func setUI(type:EditorViewType) { }
    
    private func updateAttachments() {

        print("hgjbknbh")
       // synchronizedLayer?.playerItem = self.playerItem
        guard let playerItem else {
            return
        }
        self.synchronizedLayer?.removeFromSuperlayer()

        DispatchQueue(label: "db", qos: .userInitiated).async(execute: {
            let db = DB.db.movieParameters.editingMovie
            DispatchQueue.main.async {
                let syncLayer = AVSynchronizedLayer(playerItem: self.playerItem ?? .init(asset: .init()))

                let duration = self.movie?.duration.seconds ?? .zero
              //  syncLayer.playerItem = self.playerItem
                

                print(duration, " fsdafsfdsdf ")
                db?.images.forEach({
                    self.performAddAttachment($0, videoDuration: duration, syncLayer: syncLayer)
                })
                db?.texts.forEach({
                    self.performAddAttachment($0, videoDuration: duration, syncLayer: syncLayer)
                })
                self.view.layer.addSublayer(syncLayer)
            }
        })
    }
    
    private func performAddAttachment(_ dbItem:MovieAttachmentProtocol, videoDuration:CGFloat, syncLayer:AVSynchronizedLayer) {
        print(parentVC?.viewModel?.editorModel.videoSize, " rfsedas")
        let videoSize = view.frame.size//parentVC?.viewModel?.editorModel.videoSize ?? .zero
        let redLayer = AttachentVideoLayerModel().add(to: syncLayer, videoSize: videoSize, data: dbItem, isPreview: false)
        redLayer?.name = dbItem.id.uuidString
        print(videoDuration, " refwdsa")
        let animationModel =  AnimateVideoLayer()
        animationModel.add(redLayer!,to: syncLayer, data: dbItem, totalTime: videoDuration)
    }
    
    private func overlayEdited(_ newData:AssetAttachmentProtocol?) {
        self.parentVC?.playerChangedAttachment(newData)
    }
    
    override func play(replacing: Bool = true) {
        if replacing {
            print(self.synchronizedLayer?.sublayers?.count, " refwedas ", synchronizedLayer)
        }
        super.play(replacing: false)
        if movieURL == nil {
            parentVC?.addTrackPressed()
        }
    }
    
    func videoAdded() {
        super.play(replacing: true)
        updateAttachments()
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
        self.editingAttachmentView?.playerTimeChanged(percent)
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
        print("newViewnewViewnewViewnewView")
        let newView = PlayerEditingAttachmentView.configure(data: textDB, dataChanged: overlayEdited(_:), videoSize: movie?.tracks(withMediaType: .video).first?.naturalSize ?? VideoEditorModel.renderSize)
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
