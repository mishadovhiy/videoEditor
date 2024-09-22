//
//  SinhronizedLayerVC.swift
//  VideoEditorUIkit
//
//  Created by Mykhailo Dovhyi on 03.09.2024.
//

import UIKit
import AVFoundation
import Photos

/// For testing attachments
class SinhronizedLayerVC:UIViewController {
    var player:AVPlayerLayer? {
        view.layer.sublayers?.first(where:{$0 is AVPlayerLayer}) as? AVPlayerLayer
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .red
        self.view = view
        addVideo()
    }
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if player?.player?.rate ?? .zero <= .zero {
            player?.player?.play()
            player?.player?.seek(to: .zero)
        } else {
            player?.player?.pause()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
        let asset = self.player?.player?.currentItem?.asset ?? .init()
        
        /* DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
         Task {
         let export = AVAssetExportSession(asset:asset, presetName: VideoEditorModel.exportPresetName)
         let results = await export?.exportVideo(videoComposition: asset)
         if let url = results?.videoExportResponse?.url {
         await MainActor.run {
         PHPhotoLibrary.shared().performChanges({
         PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
         }) { success, error in
         if success {
         
         }
         }
         }
         }
         }
         })*/
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        player?.frame = view.bounds
        player?.player?.seek(to: .zero)
        player?.player?.play()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addVideo() {
        let playerLayer = AVPlayerLayer(player: .init())
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
    }
    
    func playVideo() {
        guard let videoURL = Bundle.main.url(forResource: "1", withExtension: "mov") else {
            print("Movie error")
            return
        }
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        if player?.player == nil {
            return
        } else {
            player?.player?.replaceCurrentItem(with: playerItem)
        }
        
        if player == nil {
            fatalError()
        }
        
        player?.backgroundColor = UIColor.red.cgColor
        
        let synchronizedLayer = AVSynchronizedLayer()
        synchronizedLayer.playerItem = playerItem
        
        //for db add animations
        synchronizedLayer.frame = self.view.bounds
        self.view.layer.sublayers?.forEach({
            if $0 is AVSynchronizedLayer {
                $0.removeFromSuperlayer()
            }
        })
        
        addItems(synchronizedLayer, duration: asset.duration.seconds)
        player?.player?.play()
    }
    
    func addItems(_ synchronizedLayer:CALayer, duration:CGFloat) {
        let db = DB.db.movieParameters.editingMovie?.texts ?? []
        self.view.layer.addSublayer(synchronizedLayer)
        db.forEach { dbItem in
            //    let dbItem = testDB()
            let redLayer = AttachentVideoLayerModel().add(to: synchronizedLayer, videoSize: UIApplication.shared.keyWindow?.frame.size ?? .zero, data: dbItem)
            redLayer?.opacity = 0
            redLayer?.name = dbItem.id.uuidString
            
            let animationModel = AnimateVideoLayer()
            animationModel.add(redLayer, to: synchronizedLayer, data: dbItem, totalTime: duration)
        }
        
//test: add sync layer before adding sublayers to sync layer
    }
}

extension SinhronizedLayerVC {
    static func configure() -> SinhronizedLayerVC {
        let vc = SinhronizedLayerVC()
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

extension SinhronizedLayerVC {
    func animationTest(isTest:Bool = false) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = .greatestFiniteMagnitude
        animation.beginTime = isTest ? .zero : (AVCoreAnimationBeginTimeAtZero + 2)
        // animation.repeatDuration = 50
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    func testDB() -> TextAttachmentDB {
        var value = TextAttachmentDB()
        value.position = .init(x: 0.5, y: 0.5)
        value.assetName = "text value"
        value.time = .with({
            $0.start = 0.1
            $0.duration = 0.5
        })
        value.animations = .with({
            $0.appeareAnimation = .with({
                $0.duration = 0.5
                $0.key = .opacity
                $0.valueFloat = 1
            })
            $0.disapeareAnimation = .with({
                $0.duration = 0.5
                $0.key = .opacity
                $0.valueFloat = 0.1
            })
            $0.repeatedAnimations = .with({
                $0.duration = 0.4
                $0.key = .scale
                $0.valueFloat = 0.1
            })
        })
        return value
    }
    
}
