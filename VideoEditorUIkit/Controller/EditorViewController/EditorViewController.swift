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
    var playerVC:PlayerViewController? {
        return self.children.first(where: {$0 is PlayerViewController
        }) as? PlayerViewController
    }
    
    private var assetParametersVC:AssetParametersViewController? {
        return self.children.first(where: {$0 is AssetParametersViewController
        }) as? AssetParametersViewController
    }
    var viewModel:EditorModel!

    override func loadView() {
        super.loadView()
        loadUI(movieUrl: lastEditedVideoURL())
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
    
    func addTextPressed(data:MovieAttachmentProtocol? = nil) {
        viewModel.addText(data ?? TextAttachmentDB.demo)
    }
}


extension EditorViewController:PlayerViewControllerPresenter {
    func reloadUI() {
        UIApplication.shared.keyWindow?.rootViewController = EditorViewController.configure()
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        self.view.removeFromSuperview()
        self.viewModel = nil
        self.removeFromParent()
    }
    
    func clearDataPressed() {
        movieURL = nil
        Task {
            DB.db.movieParameters = .init(dict: [:])
            await MainActor.run {
                self.reloadUI()
            }
        }
    }
    
    func playTimeChanged(_ percent: CGFloat) {
        print("EditorViewControllerpercent")
        assetParametersVC?.scrollPercent(percent)
    }
    
    func addTrackPressed() {
        self.viewModel.addVideo()
    }
}


extension EditorViewController:ViewModelPresenter {
    @MainActor func deleteAllData() {
        self.reloadUI()
    }
    
    var movieURL: URL? {
        get {
            self.playerVC?.movieURL
        }
        set {
            playerVC?.movieURL = newValue
            Task {
                DB.db.movieParameters.clearTemporaryDirectory(exept: newValue)
            }
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
        Task {
            DB.db.movieParameters.clearTemporaryDirectory(exept: movieURL)
        }
    }
}



//MARK: loadUI
fileprivate extension EditorViewController {
    func loadUI(movieUrl:URL?) {
        view.backgroundColor = .black
        addPlayerView()
        if viewModel == nil {
            viewModel = .init(presenter:self)
            loadVideo(movieUrl: movieUrl)
        }
        addTracksView()
    }
    
    private func loadVideo(movieUrl:URL? = nil) {
        if movieURL == nil {
            self.movieURL = movieUrl ?? lastEditedVideoURL()
        }
        playerVC?.startRefreshing {
            if let movie = movieUrl ?? self.movieURL {
                self.viewModel.loadVideo(movie, canShowError: false)
            } else {
                self.viewModel.addVideo()
            }
        }
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

