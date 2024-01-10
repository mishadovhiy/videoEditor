//
//  ViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AVFoundation

class EditorViewController: SuperVC {

    @IBOutlet private weak var trackContainerView: UIView!
    @IBOutlet private weak var videoContainerView: UIView!
    var viewModel:EditorModel!

    override func loadView() {
        super.loadView()
        print(lastEditedVideoURL())
        loadUI(movieUrl: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }
    
    override var initialAnimation: Bool {
        return false
    }
    
    func seek(percent:CGFloat) {
        self.playerVC?.seek(seconds: percent * (playerVC?.movie.duration.seconds ?? 0))
    }
        
    var playerVC:PlayerViewController? {
        if !Thread.isMainThread {
            fatalError()
        }
        return self.children.first(where: {$0 is PlayerViewController}) as? PlayerViewController
    }
    
    private var assetParametersVC:AssetParametersViewController? {
        return self.children.first(where: {$0 is AssetParametersViewController}) as? AssetParametersViewController
    }
}


extension EditorViewController:PlayerViewControllerPresenter {
    func playTimeChanged(_ percent: CGFloat) {
        print("EditorViewControllerpercent")
        assetParametersVC?.scrollPercent(percent)
    }
    
    func addTrackPressed() {
        self.viewModel.addVideo()
    }
}


extension EditorViewController:ViewModelPresenter {
    var movieURL: URL? {
        get {
            self.playerVC?.movieURL
        }
        set {
            clearTemporaryDirectory(exept: newValue)
            playerVC?.movieURL = newValue
        }
    }
    
    @MainActor func videoAdded() {
        self.playerVC?.seek(seconds: .zero)
        playerVC?.durationLabel?.text = "\(playerVC?.movie.duration.seconds ?? 0)"
        self.playerVC?.endRefreshing {
            self.playerVC?.play(replacing: true)
        }
    }
    
    @MainActor func errorAddingVideo() {
        AppDelegate.shared.ai.showAlert(title: "Error", appearence: .type(.error))
        self.playerVC?.endRefreshing()
        self.playerVC?.pause()
        self.clearTemporaryDirectory(exept: movieURL)
    }
}



//MARK: loadUI
fileprivate extension EditorViewController {
    func loadUI(movieUrl:URL?) {
        view.backgroundColor = .black
        addPlayerView()
        if viewModel == nil {
            viewModel = .init(presenter:self)
            self.movieURL = movieUrl
            if movieUrl == nil {
                playerVC?.startRefreshing {
                    self.viewModel.addVideo()
                }
            } else {
                if let movieUrl {
                    self.viewModel.loadVideo(movieUrl, canShowError: false)
                }
            }
            
        }
        addTracksView()
    }
    
    private func addPlayerView() {
        if playerVC != nil {
            return
        }
        let vc = PlayerViewController.configure(self)
        self.addChild(child: vc, toView: self.videoContainerView)
    }


    private func addTracksView() {
        let vc = AssetParametersViewController.configure()
        addChild(child: vc, toView: self.trackContainerView)
    }
}


extension EditorViewController {
    static func configure() -> EditorViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController ?? .init()
        return vc
    }
}
