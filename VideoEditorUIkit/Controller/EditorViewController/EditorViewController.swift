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
    private var viewModel:EditorViewModel!

    override func loadView() {
        super.loadView()
        loadUI()
    }
    
    private var playerVC:PlayerViewController? {
        return self.children.first(where: {$0 is PlayerViewController}) as? PlayerViewController
    }
}


extension EditorViewController:PlayerViewControllerPresenter {
    func addTrackPressed() {
        self.viewModel.addVideo()
    }
}


extension EditorViewController:ViewModelPresenter {
    @MainActor var movie: AVMutableComposition {
        return playerVC?.movie ?? .init()
    }
    
    @MainActor func videoAdded() {
        self.playerVC?.endRefreshing {
            self.playerVC?.play()
        }
    }
    
    @MainActor func errorAddingVideo() {
        AppDelegate.shared.ai.showAlert(title: "Error", appearence: .type(.error))
        self.playerVC?.endRefreshing()
    }
}


//MARK: loadUI
fileprivate extension EditorViewController {
    func loadUI() {
        view.backgroundColor = .black
        addPlayerView()
        if viewModel == nil {
            viewModel = .init(presenter:self)
            playerVC?.startRefreshing {
                self.viewModel.addVideo()
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
        let vc = TrackListView(model:viewModel.model ?? .init())
        self.addSwiftUIView(vc, toView: trackContainerView)
    }
}
