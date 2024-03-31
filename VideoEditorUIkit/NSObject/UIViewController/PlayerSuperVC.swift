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
    var movie:AVAsset? {
        return playerLayer?.player?.currentItem?.asset ?? (movieURL != nil ? .init(url: movieURL!) : nil)
    }
    
    private var timeObserverIgonre = false
    private var playTimeChangedAnimation:UIViewPropertyAnimator? = UIViewPropertyAnimator(duration: 0.8, curve: .easeIn)
    
    private var playProgressView:UIProgressView? {
        return view.subviews.first(where: {$0.layer.name == "playProgressView"}) as? UIProgressView
    }
    
    private var noDataView:UIStackView? {
        return view.subviews.first(where: {$0.layer.name == "noDataView"}) as? UIStackView
    }
    
    fileprivate var playerItem:AVPlayerItem? {
        guard let movieURL else {
            return nil
        }
        return .init(url: movieURL)
    }
    
    private var durationLabel:UILabel? {
        return view.subviews.first(where: {$0.layer.name == "durationLabel"}) as? UILabel
    }
    
    private var playerLayer:AVPlayerLayer? {
        return self.view.layer.sublayers?.first(where: {$0.name == "PrimaryPlayer"}) as? AVPlayerLayer
    }
    
    // MARK: Life cycle
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
        addPlayerTimeObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.navigationController == nil {
            self.removeFromParent()
        }
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.layer.bounds
    }
    
    override func removeFromParent() {
        playerLayer?.player?.pause()
        playerLayer?.player = nil
        playerLayer?.removeFromSuperlayer()
        removeAllObservers()
        playTimeChangedAnimation?.stopAnimation(true)
        playTimeChangedAnimation = nil
        super.removeFromParent()
    }
    
    // MARK: public
    override func endRefreshing(completion: (() -> ())? = nil) {
        super.endRefreshing(completion: {
            self.showNoDataView(show: self.movieURL == nil)
            completion?()
        })
    }
    
    override func startRefreshing(canReturn:Bool = false, completion: (() -> ())? = nil) {
        super.startRefreshing(canReturn: canReturn, completion: completion)
        showNoDataView(show: false)
    }
    
    func playerTimeChanged(_ percent:CGFloat) { }
    
    func pause() {
        isPlaying = false
        playerLayer?.player?.pause()
    }
    
    func seek(seconds:TimeInterval, manual:Bool = false) {
        print("seeking: ", seconds)
        if playerLayer?.player?.currentItem == nil {
            return
        }
        timeObserverIgonre = manual
        if !manual {
            self.pause()
        }
        let desiredCMTime = CMTime(seconds: seconds, preferredTimescale: VideoEditorModel.timeScale)

        playerLayer?.player?.seek(to: desiredCMTime, completionHandler: {
            if !$0 {
                return
            }
            self.removePlayTimeObserver()
            self.performTimeChanged(seconds)
            self.addPlayerTimeObserver()
        })
    }
    
    func play(replacing:Bool = true) {
        guard let item = playerItem else { return}
        if let playerLayer = self.playerLayer,
           let player = playerLayer.player
        {
            if replacing {
                player.replaceCurrentItem(with: item)
            }
            if player.currentItem != nil && player.currentTime() == player.currentItem?.duration {
                self.seek(seconds: .zero)
            }
            if player.currentItem?.duration != .zero {
                preparePlayer()
                player.play()
            }
        } else {
            self.addPlayerView()
            play()
        }
    }
    
    func removePlayer() {
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
    }
    
    func preparePlayer() { }
    
    //MARK: IBActions
    @objc fileprivate func playPressed(_ sender:UIButton) {
        if isPlaying {
            self.pause()
        } else {
            self.play(replacing: false)
        }
    }
    
    private func playingTimeObserverChanged(_ sendond:TimeInterval) {
        print("Current Time: \(sendond)")
        if sendond == movie?.duration.seconds {
            let playing = self.playerLayer?.player?.rate != 0
            print("completed ", playing)
            self.pause()
        }
        let percent = sendond / (movie?.duration.seconds ?? 0)
        performTimeChanged(sendond)
        if !timeObserverIgonre {
            playerTimeChanged(percent)
        } else {
            timeObserverIgonre = false
        }
    }
}

// MARK: observers
fileprivate extension PlayerSuperVC {
    private func addPlayerTimeObserver() {
        let timeInterval = CMTime(seconds: 0.01, preferredTimescale: VideoEditorModel.timeScale)
        self.timeChangeObserver = self.playerLayer?.player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) { [weak self] time in
            self?.playingTimeObserverChanged(CMTimeGetSeconds(time))
        }
    }
    
    private func removeAllObservers(delete:Bool = true) {
        removePlayTimeObserver()
    }
    
    private func removePlayTimeObserver() {
        if let timeChangeObserver {
            playerLayer?.player?.removeTimeObserver(timeChangeObserver)
            self.timeChangeObserver = nil
        }
    }
}

//MARK: - setupUI
fileprivate extension PlayerSuperVC {
    private func performTimeChanged(_ seconds:TimeInterval) {
        let percent = seconds / (movie?.duration.seconds ?? 0)
        playProgressView?.progress = Float(percent)
        playProgressView?.tintColor = .type(.white)
        durationLabel?.text = seconds.stringTime + "/" + (movie?.duration.seconds.stringTime ?? "-")
    }
    
    private func pauseStateChanged(_ pause:Bool) {
        let button = view.subviews.first(where: {$0.layer.name == "playButton"}) as? UIButton
        playTimeChangedAnimation?.stopAnimation(true)
        button?.alpha = 1
        button?.setImage(.init(named: !pause ? "pause" : "play"), for: .normal)
        isPlaying = !pause
        if !pause {
            playTimeChangedAnimation?.addAnimations {
                button?.alpha = !pause ? 0 : 1
            }
            playTimeChangedAnimation?.startAnimation()
        }
    }
}

//MARK: - loadUI
fileprivate extension PlayerSuperVC {
    func loadUI() {
        addPlayerView()
        addPlayButton()
        addNoDataView()
        addLabel()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playPressed(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    private func addLabel() {
        if let _ = durationLabel {
            return
        }
        let label = UILabel()
        label.layer.name = "durationLabel"
        label.isUserInteractionEnabled = false
        label.textColor = .init(.greyText)
        label.font = .type(.smallMedium)
        self.view.addSubview(label)
        label.addConstaits([.right:0, .bottom:0])
    }
    
    private func addPlayButton() {
        if let _ = view.subviews.first(where: {$0.layer.name == "playButton"}) {
            return
        }
        let button = UIButton()
        button.setImage(.init(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(self.playPressed(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.layer.name = "playButton"
        let color:UIColor = .type(.greyText)
        button.tintColor = color.withAlphaComponent(0.16)
        button.titleLabel?.font = .type(.smallMedium)
        button.layer.shadowColor = UIColor.type(.black).cgColor
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.3
        button.isUserInteractionEnabled = false
        button.addConstaits([
            .centerX:0, .centerY:0, .width:40, .height:40
        ])
    }
    
    private func addNoDataView() {
        let stack = UIStackView()
        stack.layer.name = "noDataView"
        view.addSubview(stack)
        
        let label = UILabel()
        stack.addArrangedSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .type(.greyText)
        label.font = .type(.regulatMedium)
        label.text = "Start Adding video from\nPhoto Library"
        
        stack.addConstaits([.centerX:0, .centerY:100, .width:view.frame.width])
    }
    
    private func addPlayerView() {
        if let playerLayer = self.playerLayer,
           let _ = playerLayer.player
        {
            return
        }
        guard let playerItem else {
            return
        }
        let player = Player(playerItem:playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.layer.bounds
        playerLayer.videoGravity = .resizeAspect
        playerLayer.name = "PrimaryPlayer"
        player.pauseChanged = pauseStateChanged(_:)
        view.layer.addSublayer(playerLayer)

        addPlayerTimeObserver()
        
        let progressView:UIProgressView = .init()
        progressView.isUserInteractionEnabled = false
        progressView.layer.name = "playProgressView"
        view.addSubview(progressView)
        progressView.addConstaits([.left:0, .right:0, .bottom:0, .height:3], safeArea: true)
    }
    
    private func showNoDataView(show:Bool, completion:(()->())? = nil) {
        let animation = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut) {
            self.noDataView?.alpha = show ? 1 : 0
        }
        if let completion {
            animation.addCompletion({ _ in
                completion()
            })
        }
        animation.startAnimation()
    }
}

