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

    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet private weak var trackContainerView: UIView!
    @IBOutlet private weak var videoContainerView: UIView!
    var viewModel:EditorViewModel!

    override func loadView() {
        super.loadView()
        loadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }
    
    override var initialAnimation: Bool {
        return false
    }
    
    @IBAction private func progressChanged(_ sender: Any) {
        let value = Double((sender as? UISlider)?.value ?? 0)
        self.playerVC?.seek(seconds: value * movie.duration.seconds)
    }
        
    private var playerVC:PlayerViewController? {
        return self.children.first(where: {$0 is PlayerViewController}) as? PlayerViewController
    }
}


extension EditorViewController:PlayerViewControllerPresenter {
    func playTimeChanged(_ percent: CGFloat) {
        print("EditorViewControllerpercent")
      //  trackView?.performScroll(percent: percent)
        self.progressSlider.value = Float(percent)
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
            playerVC?.movieURL = newValue
        }
    }
    
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


extension EditorViewController:TrackListViewPresenter {
    func scrollChanged(_ percent: CGFloat) {
        print(percent, " efrwewledn")
        
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
