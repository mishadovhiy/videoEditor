//
//  ViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AVFoundation
import SwiftUI

class EditorViewController: SuperVC {

    @IBOutlet private weak var trackContainerView: UIView!
    @IBOutlet private weak var videoContainerView: UIView!
    var viewModel:EditorModel!

    override var initialAnimation: Bool {
        return false
    }
    override func loadView() {
        super.loadView()
//        DispatchQueue(label: "db", qos: .userInitiated).async {
//            let url = self.lastEditedVideoURL()
//            DispatchQueue.main.async {
//                self.loadUI()
//                self.playerVC?.movieURL = url
//                self.playerVC?.play(replacing: true)
//            }
//        }
        self.loadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }
    
    func seek(percent:CGFloat) {
       
        self.playerVC?.seek(seconds: percent * (playerVC?.movie.duration.seconds ?? 0))
    }
        
    var playerVC:PlayerViewController? {
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
        self.viewModel.addVideo(text: false)
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
    func loadUI() {
        view.backgroundColor = .black
        addPlayerView()
        if viewModel == nil {
            viewModel = .init(presenter:self)
            if self.movieURL == nil {
                playerVC?.startRefreshing {
                    self.viewModel.addVideo(text: true)
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
