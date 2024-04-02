//
//  ViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AVFoundation
import MediaPlayer

class EditorViewController: SuperVC {
    
    @IBOutlet private weak var trackContainerView: UIView!
    @IBOutlet private weak var videoContainerView: UIView!
    @IBOutlet private weak var mainEditorContainerView: UIView!
    
    var playerVC:PlayerViewController? {
        return self.children.first(where: {$0 is PlayerViewController
        }) as? PlayerViewController
    }
    
    private var assetParametersVC:EditorParametersViewController? {
        children.first(where: {$0 is EditorParametersViewController
        }) as? EditorParametersViewController
    }
    
    var mainEditorVC:EditorOverlayVC? {
        children.first(where: {
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
    var viewModel:EditorVCViewMode?
    
    private let setupAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    // MARK: - Life-cycle
    override func loadView() {
        super.loadView()
        loadUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainEditorVC?.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30), execute: {
            self.mainEditorVC?.isHidden = true
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.deinit()
        viewModel = nil
    }
    
    // MARK: - setup ui
    func setViewType(_ type:EditorViewType, overlaySize:EditorOverlayContainerVC.OverlaySize = .small) {
        self.viewModel?.viewType = type
        setupAnimation.stopAnimation(true)
        setupAnimation.addAnimations {
            self.playerVC?.setUI(type: type)
            self.assetParametersVC?.setUI(type: type, overlaySize: overlaySize)
        }
        setupAnimation.startAnimation()
        if view.superview == nil {
            return
        }
        if viewModel?.editorModel.movie != nil {
            mainEditorVC?.canSetHidden = type != .addingVideos && viewModel?.editorModel.movie != nil
        } else {
            mainEditorVC?.canSetHidden = true
        }
    }
    
    private func loadVideo(movieUrl:URL? = nil) {
        let url = movieUrl ?? self.movieURL
        if let url {
            setViewType(.editing)
            startRefreshing {
                self.viewModel?.editorModel.loadVideo(url, canShowError: false)
            }
        } else {
            viewModel?.viewType = .addingVideos
            videoAdded()
        }
    }
    
    override var isAnimating: Bool {
        get {
            return playerVC?.isAnimating ?? false
        }
        set {
            playerVC?.isAnimating = newValue
        }
    }
    
    override func startRefreshing(canReturn: Bool = false, completion: (() -> ())? = nil) {
        playerVC?.startRefreshing(canReturn: canReturn, completion: completion)
    }
    
    override func endRefreshing(completion: (() -> ())? = nil) {
        playerVC?.endRefreshing(completion: completion)
    }
    
    // MARK: - receive
    func previewImagesUpdated(image:Data?) {
        if viewModel?.viewType == .addingVideos {
            self.mainEditorVC?.updateData(viewModel?.addingVideosEditorData(pressed: self.viewModelPrimaryPressed(_:)))
        } else {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                let data = DB.db.movieParameters.editingMovie?.preview
                DispatchQueue.main.async {
                    self.mainEditorVC?.updateData(self.viewModel?.mainEditorCollectionData(pressed: self.viewModelPrimaryPressed(_:), filterPreviewImage: data) ?? [])
                }
            }
        }
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
    func viewModelPrimaryPressed(_ action:EditorVCViewMode.OverlayPressedModel) {
        switch action {
        case .reload:
            reloadUI()
        case .delete:
            clearDataPressed()
        case .filterSelected:
            videoFilterSelected()
        case .toStoredVideos:
            self.coordinator?.toList(tableData: viewModel?.storedVideosTableData(parentVC: self) ?? [])
        case .export:
            startRefreshing(canReturn: true, completion: {
                self.viewModel?.editorModel.exportToLibraryPressed()
            })
        case .startAnimating(completed: let completed):
            startRefreshing(completion: completed)
        }
    }
    
    func seek(percent:CGFloat, manual:Bool = false) {
        self.playerVC?.seek(seconds: percent * (playerVC?.movie?.duration.seconds ?? 0), manual: manual)
    }
    
    public func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        startRefreshing(canReturn: true, completion: {
            self.viewModel?.editorModel.addAttachmentPressed(data)
        })
    }
    
    func videoFilterSelected() {
        startRefreshing(canReturn: true, completion: {
            self.viewModel?.editorModel.addFilterPressed()
        })
    }
    
    private func videoSelectedFrom(url:URL?, controller:UIViewController) {
        if let url {
            startRefreshing(canReturn: true, completion: {
                controller.dismiss(animated: true) {
                    self.viewModel?.editorModel.addVideo(url: url)
                }
            })
        } else {
            print("no video urlss")
            audioToolBox?.vibrate(style: .error)
        }
    }
    
    func addTrackPressed() {
        if viewModel?.viewType == .addingVideos {
            coordinator?.toPhotoLibrary(delegate: self, isVideo: true)
        } else {
            mainEditorVC?.isHidden = false
        }
    }
    
    @IBAction func startEditingPressed(_ sender: Any) {
        audioToolBox?.vibrate()
        mainEditorVC?.isHidden = true
        startRefreshing(completion: {
            self.reloadUI()
        })
    }
    
    func uploadFromPressed(type: EditorOverlayContainerVCViewModel.UploadPressedType) {
        switch type {
        case .appleMusic:
            coordinator?.toAppleMusicList(delegate: self)
        case .files:
            coordinator?.toDocumentPicker(delegate: self)
        case .photoLibrary:
            coordinator?.toPhotoLibrary(delegate: self)
        }
    }
    
    private func performSongToVideoSelected(_ url:URL) {
        var songData = self.assetParametersVC?.viewModel?.editingAsset as? SongAttachmentDB ?? SongAttachmentDB()
        songData.attachmentURL = url.absoluteString
        self.assetParametersVC?.viewModel?.editingAsset = songData
        self.presentingOverlayVC?.updateData(nil)
        (self.assetParametersVC?.viewModel?.editingView as? AssetRawView)?.updateText(songData, totalVideoDuration: self.viewModel?.editorModel.movieDuration ?? 0)
    }
    
    private func soundToVideoSelected(_ url:URL, controller:UIViewController) {
        startRefreshing(canReturn: true, completion: {
            controller.dismiss(animated: true) {
                self.performSongToVideoSelected(url)
            }
        })
    }
}

extension EditorViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            coordinator?.showErrorAlert(title: "Invalid file URL", description: "Check if file is downloaded")
            return
        }
        soundToVideoSelected(selectedURL, controller: controller)
    }
}

extension EditorViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let item = mediaItemCollection.items.first
        guard let url = item?.assetURL else {
            print("url is nil")
            coordinator?.showErrorAlert(title: "Selected Song is not downloaded or DRM protected from copying", description: "Try to download the media in the Apple Music app and try again")
            return
        }
        soundToVideoSelected(url, controller: mediaPicker)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
}

extension EditorViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let mediaType = info[UIImagePickerController.InfoKey.mediaType]
            print("didFinishPickingMediaWithInfo ", info)
            var asset = assetParametersVC?.viewModel?.editingAsset as? ImageAttachmentDB
            if asset != nil, 
                let assetView = assetParametersVC?.viewModel?.editingView as? AssetRawView,
               let pickedImage
        {
                picker.dismiss(animated: true) {
                    asset?.image = pickedImage.jpegData(compressionQuality: 0.5)
                    self.presentingOverlayVC?.updateData(nil)
                    assetView.updateText(asset, totalVideoDuration: self.viewModel?.editorModel.movieDuration ?? 0)
                    self.playerVC?.editingAttachmentView?.data = asset
                }
            } else if let videoURL = url {
                videoSelectedFrom(url: videoURL, controller: picker)
            }
    }
}

extension EditorViewController:PlayerViewControllerPresenter {
    func reloadUI() {
        viewModel?.editorModel.movie = nil
        viewModel?.editorModel.movieHolder = nil
        loadVideoDB()
    }
    
    func clearDataPressed() {
        Task {
            DB.db.movieParameters = .init(dict: [:])
            await MainActor.run {
                self.movieURL = nil
                self.reloadUI()
            }
        }
    }
    
    func playTimeChanged(_ percent: CGFloat) {
        assetParametersVC?.scrollPercent(percent)
    }
}

extension EditorViewController:VideoEditorModelPresenter {
    var movieURL: URL? {
        get {
            if Thread.isMainThread {
                return self.playerVC?.movieURL
            } else {
                return .init(string: DB.db.movieParameters.editingMovieURL ?? "")
            }
        }
        set {
            if newValue == nil {
                self.mainEditorVC?.isHidden = true
            }
            Task {
                AppDelegate.shared?.fileManager?.clearDirectory(newValue)
            }
            playerVC?.movieURL = newValue
        }
    }
    
    @MainActor func videoAdded() {
        assetParametersVC?.assetChanged()
        previewImagesUpdated(image: nil)
        setViewType(viewModel?.viewType ?? .addingVideos)
        endRefreshing(completion: {
            if self.movieURL == nil {
                self.playerVC?.removePlayer()
            } else {
                self.playerVC?.play(replacing: true)
            }
        })
    }
    
    @MainActor func errorAddingVideo(_ text:MessageContent?) {
        coordinator?.showErrorAlert(title: text?.title ?? "", description: text?.description)
        endRefreshing()
        playerVC?.pause()
    }
}

//MARK: loadUI
fileprivate extension EditorViewController {
    func loadUI() {
        if viewModel == nil {
            viewModel = .init(editorPresenter: self)
        }
        loadChildrens()
        loadVideoDB()
        trackContainerView.layer.zPosition = 2
        mainEditorVC?.overlaySizeChanged = {
            self.setViewType(self.viewModel?.viewType ?? .editing, overlaySize: $0)
        }
        previewImagesUpdated(image: nil)
    }
    
    private func loadVideoDB() {
        Task {
            let url = lastEditedVideoURL
            self.viewModel?.viewType = url == nil ? .addingVideos : .editing
            await MainActor.run {
                self.loadVideo(movieUrl: url)
            }
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
}


extension EditorViewController {
    static func configure() -> EditorViewController {
        let vc = UIStoryboard(name: "Editor", bundle: nil).instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController ?? .init()
        return vc
    }
}

