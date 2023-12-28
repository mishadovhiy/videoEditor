//
//  PlayerSuperVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

class PlayerSuperVC: SuperVC {
    var movie = AVMutableComposition()
    
    override func loadView() {
        super.loadView()
        self.loadUI()
    }
    
    func play() {
        print(#function)
        let item = AVPlayerItem(asset: movie)
        if let playerLayer = self.view.layer.sublayers?.first(where: {$0.name == "PrimaryPlayer"}) as? AVPlayerLayer,
           let player = playerLayer.player
        {
            print(#function, " start")
            player.replaceCurrentItem(with: item)
            player.play()
        } else {
            self.addPlayerView()
            play()
        }
    }
    
    @objc fileprivate func playPressed(_ sender:UIButton) {
        self.play()
    }
}


//MARK: loadUI
fileprivate extension PlayerSuperVC {
    func loadUI() {
        addPlayerView()
        addPlayButton()
    }
    
    private func addPlayButton() {
        if let _ = view.subviews.first(where: {$0.layer.name == "playButton"}) {
            return
        }
        let button = UIButton()
        button.setTitle("play", for: .normal)
        button.addTarget(self, action: #selector(self.playPressed(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.layer.name = "playButton"
        button.addConstaits([
            .bottom:10, .left:10, .right:10
        ], superView: view)
    }
    
    
    
    private func addPlayerView() {
        if let playerLayer = view.layer.sublayers?.first(where: {$0.name == "PrimaryPlayer"}) as? AVPlayerLayer,
           let _ = playerLayer.player
        {
            return
        }
        print(#function)
        let player = AVPlayer(playerItem: AVPlayerItem(asset: movie))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.layer.bounds
        playerLayer.videoGravity = .resizeAspect
        playerLayer.name = "PrimaryPlayer"
        view.layer.addSublayer(playerLayer)
    }
}
