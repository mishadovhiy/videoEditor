//
//  ViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AVFoundation

class EditorViewController: SuperVC {

    @IBOutlet weak var startEditingButton: BaseButton!
    @IBOutlet private weak var trackContainerView: UIView!
    @IBOutlet private weak var videoContainerView: UIView!
    @IBOutlet private weak var mainEditorContainerView: UIView!
    
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
        loadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.deinit()
        viewModel = nil
    }
    
    // MARK: - setup ui
    func setViewType(_ type:EditorViewType, overlaySize:EditorOverlayContainerVC.OverlaySize = .small) {
        self.viewModel?.viewType = type
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.playerVC?.setUI(type: type)
            self.assetParametersVC?.setUI(type: type, overlaySize: overlaySize)
        }
        self.hideStartEditing(!(type == .addingVideos && movieURL != nil), animation: animation)
        animation.startAnimation()
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
    
    // MARK: - receive
    private func newVideoAdded() {
        self.playerVC?.seek(seconds: .zero)
        playerVC?.durationLabel?.text = "\(playerVC?.movie?.duration.seconds ?? 0)"
        self.playerVC?.endRefreshing {
            self.playerVC?.play(replacing: true)
        }
        self.assetParametersVC?.assetChanged()
    }
    
    func previewImagesUpdated(image:Data?) {
        mainEditorVC?.updateData(viewModel?.mainEditorCollectionData(vc:self, filterPreviewImage: image, filterSelected:videoFilterSelected, reloadPressed: reloadUI, removeAttachments: {
            self.viewModel?.editorModel.addSoundPressed()
        }, deleteMovie: {
            self.clearDataPressed()
        }) ?? [])
    }
    
    func playerChangedAttachment(_ newData:AssetAttachmentProtocol?) {
        presentingOverlayVC?.attachmentData = newData
        self.assetParametersVC?.changeDataWithoutReload(newData)
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
        viewModel?.editorModel.addAttachmentPressed(data)
    }
    
    func videoFilterSelected() {
        playerVC?.startRefreshing(completion: {
            self.viewModel?.editorModel.addFilterPressed()
        })
    }
    
    func addTrackPressed() {
        if viewModel?.viewType == .addingVideos {
            playerVC?.startRefreshing(completion: {
                self.viewModel?.editorModel.addVideo()
            })
        } else {
            mainEditorVC?.isHidden = false
        }
    }
    
    @IBAction func startEditingPressed(_ sender: Any) {
        hideStartEditing(true, animation: nil)
        playerVC?.startRefreshing(completion: {
            self.reloadUI()
        })
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
            await MainActor.run {
                self.reloadUI()
            }
        }
    }
    
    func playTimeChanged(_ percent: CGFloat) {
        assetParametersVC?.scrollPercent(percent)
    }
}


extension EditorViewController:EditorModelPresenter {
    var movieURL: URL? {
        get {
            if Thread.isMainThread {
                return self.playerVC?.movieURL
            } else {
                return .init(string: DB.db.movieParameters.editingMovieURL ?? "")
            }
        }
        set {
            Task {
                DB.db.movieParameters.clearTemporaryDirectory(exept: newValue)
                await MainActor.run {
                    playerVC?.movieURL = newValue
                    if viewModel?.viewType ?? .addingVideos == .addingVideos {
                        setViewType(viewModel?.viewType ?? .addingVideos)
                    }
                }
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
    }
}

//MARK: loadUI
fileprivate extension EditorViewController {
    func loadUI() {
        if viewModel == nil {
            viewModel = .init(editorPresenter: self)
        }
        loadChildrens()
        loadVideo(movieUrl: lastEditedVideoURL())
        trackContainerView.layer.zPosition = 2
        mainEditorVC?.overlaySizeChanged = {
            self.setViewType(self.viewModel?.viewType ?? .editing, overlaySize: $0)
        }
    }
    
    private func loadChildrens() {
        
        let mainEditorView = EditorOverlayVC.configure(data: .init(screenTitle: "Choose filter", collectionData: [], needTextField: false, isPopup: false, closePressed: {
            self.mainEditorVC?.isHidden = true
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
    
    private func hideStartEditing(_ hidden:Bool, animation:UIViewPropertyAnimator?) {
        if startEditingButton.isHidden == hidden {
            return
        }
        if !hidden {
            self.performMoveEditingButton(true)
            self.startEditingButton.isHidden = false
        }
        if animation != nil {
            animation?.addAnimations {
                self.performMoveEditingButton(hidden)
            }
            animation?.addCompletion({ _ in
                self.startEditingButton.isHidden = hidden
            })
        } else {
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.performMoveEditingButton(hidden)
            }
            animation.addCompletion({ _ in
                self.startEditingButton.isHidden = hidden
            })
            animation.startAnimation()
        }
    }
    
    func performMoveEditingButton(_ hidden:Bool) {
        startEditingButton.layer.move(.top, value: hidden ? -startEditingButton.frame.maxY : 0)
    }
}


extension EditorViewController {
    static func configure() -> EditorViewController {
        let vc = UIStoryboard(name: "Editor", bundle: nil).instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController ?? .init()
        return vc
    }
}

