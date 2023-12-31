//
//  PlayerSuperVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

class PlayerSuperVC: SuperVC {
    fileprivate var timeChangeObserver:Any?
    var isPlaying:Bool = false
    var movieURL:URL?
    
    override func loadView() {
        super.loadView()
        self.loadUI()
    }
    
    override func applicationDidHide() {
        super.applicationDidHide()
        self.pause()
        removeAllObservers()
    }
    
    override func applicationDidAppeare() {
        super.applicationDidAppeare()
        addObservers()
    }
    
    func timeChanged(_ percent:CGFloat) {
        
    }
    
    func pause() {
        playerLayer?.player?.pause()
    }
    
    func seek(seconds:TimeInterval) {
        print(#function)
        self.pause()
        let desiredCMTime = CMTime(seconds: seconds, preferredTimescale: EditorModel.timeScale)
        playerLayer?.player?.seek(to: desiredCMTime)
    }
    
    fileprivate var playerIterm:AVPlayerItem? {
        guard let movieURL else {
            return nil
        }
        return .init(url: movieURL)
       // return .init(asset: movie)
    }
    
    func play(replacing:Bool = true) {
        print(#function)
        guard let item = playerIterm else { return}
        if let playerLayer = self.playerLayer,
           let player = playerLayer.player
        {
            print(item.duration, " grefwd")
            print(item.asset, " btgrvf")

            print(#function, " ffstart ", replacing)
            if replacing {
                player.replaceCurrentItem(with: item)
            }
            preparePlayer()
            player.play()
        } else {
            self.addPlayerView()
            play()
        }
    }
    
    func preparePlayer() {
        
    }
    
    @objc fileprivate func playPressed(_ sender:UIButton) {
        if playerLayer == nil {
            return
        }
        if isPlaying {
            self.pause()
        } else {
            self.play(replacing: false)
        }
    }
    
    private func playerPauseChanged(_ pause:Bool) {
        let button = view.subviews.first(where: {$0.layer.name == "playButton"}) as? UIButton
        button?.setTitle(pause ? "resume" : "pause", for: .normal)
        isPlaying = !pause
    }
    
    private func playTimeChanged(_ sendond:TimeInterval) {
        print("Current Time: \(sendond)")
        if sendond == movie.duration.seconds {
            let playing = self.playerLayer?.player?.rate != 0
            print("completed ", playing)
            self.pause()
            self.seek(seconds: 0)
        }
        
        let percent = sendond / movie.duration.seconds
        if let line = self.view.layer.sublayers?.first(where: {$0.name == "PlayerViewControllerline"}) as? CAShapeLayer {
            line.strokeEnd = percent
        }
        durationLabel?.text = "\(Int(sendond))/\(Int(movie.duration.seconds))"
        timeChanged(percent)
    }
    
    var playerLayer:AVPlayerLayer? {
        return self.view.layer.sublayers?.first(where: {$0.name == "PrimaryPlayer"}) as? AVPlayerLayer
    }

    var movie:AVAsset {
        return playerLayer?.player?.currentItem?.asset ?? (movieURL != nil ? .init(url: movieURL!) : .init())
    }
    
    func addObservers() {
        let timeInterval = CMTime(seconds: 0.01, preferredTimescale: EditorModel.timeScale)
        self.timeChangeObserver = self.playerLayer?.player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) { [weak self] time in
            self?.playTimeChanged(CMTimeGetSeconds(time))
        }
    }
    
    func removeAllObservers(delete:Bool = true) {
        if let timeChangeObserver {
            playerLayer?.player?.removeTimeObserver(timeChangeObserver)
           // if delete {
                self.timeChangeObserver = nil
           // }
        }
    }
    
    var durationLabel:UILabel? {
        return view.subviews.first(where: {$0.layer.name == "durationLabel"}) as? UILabel
    }
}


//MARK: loadUI
fileprivate extension PlayerSuperVC {
    func loadUI() {
        addPlayerView()
        addPlayButton()
        addLabel()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playTap(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func playTap(_ sender:UITapGestureRecognizer) {
        if isPlaying {
            pause()
        } else {
            play(replacing: false)
        }
    }
    
    private func addLabel() {
        if let _ = durationLabel {
            return
        }
        let label = UILabel()
        label.layer.name = "durationLabel"
        label.isUserInteractionEnabled = false
        label.textColor = .white
        self.view.addSubview(label)
        label.addConstaits([.right:0, .bottom:0], superView: self.view)
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
        if let playerLayer = self.playerLayer,
           let _ = playerLayer.player
        {
            return
        }
        guard let playerIterm else {
            return
        }
        print(#function)
        let player = Player(playerItem:playerIterm)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.layer.bounds
        playerLayer.videoGravity = .resizeAspect
        playerLayer.name = "PrimaryPlayer"
        player.pauseChanged = playerPauseChanged(_:)
        view.layer.addSublayer(playerLayer)
        
        view.layer.drawLine([
            .init(x: 0, y: view.frame.height),
            .init(x: view.frame.width, y: view.frame.height)
        ], color: .red, width: 3, opacity: 1, name: "PlayerViewControllerline")
        
        addObservers()
    }
}



