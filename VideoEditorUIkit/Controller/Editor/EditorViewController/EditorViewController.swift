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
    @IBOutlet weak var mainEditorContainerView: UIView!
    
    var playerVC:PlayerViewController? {
        if !Thread.isMainThread {
            print("error Player called from background thread")
        }
        return self.children.first(where: {$0 is PlayerViewController
        }) as? PlayerViewController
    }
    
    private var assetParametersVC:EditorParametersViewController? {
        return self.children.first(where: {$0 is EditorParametersViewController
        }) as? EditorParametersViewController
    }
    
    var mainEditorVC:EditorOverlayVC? {
        return self.children.first(where: {
            ($0 is EditorOverlayVC) && $0.view.layer.name == "mainEditorView"
        }) as? EditorOverlayVC
    }
    
    var presentingOverlayVC:EditorOverlayVC? {
        children.first(where: {
            $0 is EditorOverlayVC && $0.view.layer.name != "mainEditorView"
        }) as? EditorOverlayVC
    }
    
    override var initialAnimation: Bool {
        return false
    }
    var viewModel:ViewModelEditorViewController?
    
    // MARK: - Life-cycle
    override func loadView() {
        super.loadView()
        loadUI(movieUrl: lastEditedVideoURL())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.deinit()
        viewModel = nil
    }
    
    // MARK: - setup ui
    func setViewType(_ type:EditorViewType) {
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.viewModel?.viewType = type
            self.playerVC?.setUI(type: type)
            self.assetParametersVC?.setUI(type: type)
        }
        animation.startAnimation()
    }
    
    // MARK: - receive
    private func newVideoAdded() {
        self.playerVC?.seek(seconds: .zero)
        playerVC?.durationLabel?.text = "\(playerVC?.movie?.duration.seconds ?? 0)"
        self.playerVC?.endRefreshing {
            self.playerVC?.play(replacing: true)
        }
        self.assetParametersVC?.assetChanged()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    // MARK: - IBAction
    func seek(percent:CGFloat) {
        self.playerVC?.seek(seconds: percent * (playerVC?.movie?.duration.seconds ?? 0))
    }
    
    public func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        playerVC?.startRefreshing {
            self.viewModel?.editorModel.addAttachmentPressed(data)
        }
    }
    
    func videoFilterSelected() {
        viewModel?.editorModel.addFilterPressed()
    }
}


extension EditorViewController:PlayerViewControllerPresenter {
    func reloadUI() {
        UIApplication.shared.keyWindow?.rootViewController = EditorViewController.configure()
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        self.view.removeFromSuperview()
        self.viewModel?.deinit()
        self.removeFromParent()
    }
    
    func clearDataPressed() {
        movieURL = nil
        Task {
            DB.db.movieParameters = .init(dict: [:])
            DB.db.movieParameters.clearTemporaryDirectory()
            await MainActor.run {
                self.reloadUI()
            }
        }
    }
    
    func playTimeChanged(_ percent: CGFloat) {
        assetParametersVC?.scrollPercent(percent)
    }
    
    func addTrackPressed() {
        if viewModel?.viewType == .addingVideos {
            viewModel?.editorModel.addVideo()
        } else {
            mainEditorContainerView.isHidden = false
        }
    }
}


extension EditorViewController:EditorModelPresenter {
    @MainActor func deleteAllData() {
        self.reloadUI()
    }
    
    var movieURL: URL? {
        get {
            if Thread.isMainThread {
                return self.playerVC?.movieURL
            } else {
                return .init(string: DB.db.movieParameters.editingMovieURL ?? "")
            }
        }
        set {
            playerVC?.movieURL = newValue
            Task {
                DB.db.movieParameters.clearTemporaryDirectory(exept: newValue, urls: DB.db.movieParameters.editingMovie?.compositionURLs)
            }
        }
    }
    
    @MainActor func videoAdded() {
        newVideoAdded()
    }
    
    @MainActor func errorAddingVideo() {
        showAlert(title: "Error", appearence: .type(.error))
        self.playerVC?.endRefreshing()
        self.playerVC?.pause()
        Task {
            DB.db.movieParameters.clearTemporaryDirectory(exept: movieURL, urls: DB.db.movieParameters.editingMovie?.compositionURLs)
        }
    }
}

//MARK: loadUI
fileprivate extension EditorViewController {
    func loadUI(movieUrl:URL?) {
        view.backgroundColor = .black
        if viewModel == nil {
            viewModel = .init(editorPresenter: self)
        }
        loadChildrens()
        if let movieUrl {
            loadVideo(movieUrl: movieUrl)
        }
    }
    
    private func loadChildrens() {
        let mainEditorView = EditorOverlayVC.configure(data: .init(screenTitle: "Choose filter", collectionData: viewModel?.mainEditorCollectionData(filterSelected:videoFilterSelected) ?? [], needTextField: false, isPopup: false, closePressed: {
            self.mainEditorContainerView.isHidden = true
        }))
        mainEditorView.view.layer.name = "mainEditorView"
        [
            PlayerViewController.configure(self): videoContainerView,
            EditorParametersViewController.configure(): trackContainerView,
            mainEditorView:mainEditorContainerView
        ].forEach {
            self.addChild(child: $0.key, toView: $0.value)
        }
    }
    
    private func loadVideo(movieUrl:URL? = nil) {
        let url = movieUrl ?? self.movieURL
        if let url {
            setViewType(.editing)
            playerVC?.startRefreshing {
                self.viewModel?.editorModel.loadVideo(url, canShowError: false)
            }
        } else {
            setViewType(.addingVideos)
        }
    }
}


extension EditorViewController {
    static func configure() -> EditorViewController {
        let vc = UIStoryboard(name: "Editor", bundle: nil).instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController ?? .init()
        return vc
    }
}

