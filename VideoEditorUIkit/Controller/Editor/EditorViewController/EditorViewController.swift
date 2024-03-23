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
    var viewModel:EditorVCViewMode?
    
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
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.playerVC?.setUI(type: type)
            self.assetParametersVC?.setUI(type: type, overlaySize: overlaySize)
        }
        animation.startAnimation()
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
            playerVC?.startRefreshing {
                self.viewModel?.editorModel.loadVideo(url, canShowError: false)
            }
        } else {
            setViewType(.addingVideos)
        }
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
            viewModel?.editorModel.exportToLibraryPressed()
        case .startAnimating(completed: let completed):
            self.playerVC?.startRefreshing(completion: completed)
        }
    }
    
    func seek(percent:CGFloat, manual:Bool = false) {
        self.playerVC?.seek(seconds: percent * (playerVC?.movie?.duration.seconds ?? 0), manual: manual)
    }
    
    public func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        viewModel?.editorModel.addAttachmentPressed(data)
    }
    
    func videoFilterSelected() {
        playerVC?.startRefreshing(completion: {
            self.viewModel?.editorModel.addFilterPressed()
        })
    }
    
    private func videoSelectedFrom(url:URL?) {
        if let url {
            playerVC?.startRefreshing(completion: {
                self.viewModel?.editorModel.addVideo(url: url)
            })
        } else {
            print("no video urlss")
            AudioToolboxService().vibrate(style: .heavy)
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
        playerVC?.startRefreshing(completion: {
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
    
    private func soundToVideoSelected(_ url:URL) {
        var songData = assetParametersVC?.viewModel?.editingAsset as? SongAttachmentDB ?? SongAttachmentDB()
        songData.attachmentURL = url.absoluteString
        assetParametersVC?.viewModel?.editingAsset = songData
        presentingOverlayVC?.updateData(nil)
        (assetParametersVC?.viewModel?.editingView as? AssetRawView)?.updateText(songData, totalVideoDuration: viewModel?.editorModel.movieDuration ?? 0)
    }
}

extension EditorViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            coordinator?.showErrorAlert(title: "Invalid file URL", description: "Check if file is downloaded")
            return
        }
        controller.dismiss(animated: true) { [weak self] in
            print("Selected file URL: \(selectedURL)")
            self?.soundToVideoSelected(selectedURL)
        }
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
        mediaPicker.dismiss(animated: true) { [weak self] in
            self?.soundToVideoSelected(url)
        }
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
                asset?.image = pickedImage.jpegData(compressionQuality: 0.5)
                presentingOverlayVC?.updateData(nil)
                assetView.updateText(asset, totalVideoDuration: viewModel?.editorModel.movieDuration ?? 0)
                playerVC?.editingAttachmentView?.data = asset
            } else if let videoURL = url {
                videoSelectedFrom(url: videoURL)
            }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditorViewController:PlayerViewControllerPresenter {
    func reloadUI() {
        coordinator?.start()
        view.removeFromSuperview()
        viewModel?.deinit()
        removeFromParent()
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
            print("moviesetts: ", newValue)
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
        playerVC?.endRefreshing {
            self.playerVC?.play(replacing: true)
        }
    }
    
    @MainActor func errorAddingVideo(_ text:MessageContent?) {
        coordinator?.showErrorAlert(title: text?.title ?? "", description: text?.description)
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
        loadVideo(movieUrl: lastEditedVideoURL)
        trackContainerView.layer.zPosition = 2
        mainEditorVC?.overlaySizeChanged = {
            self.setViewType(self.viewModel?.viewType ?? .editing, overlaySize: $0)
        }
        previewImagesUpdated(image: nil)
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

