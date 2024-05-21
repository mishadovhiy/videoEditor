//
//  TestCollectionView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 30.12.2023.
//

import UIKit
import AVFoundation

class EditorParametersViewController: SuperVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetStackView: UIStackView!
    @IBOutlet weak var headersStack: UIStackView!
    private var addVideoLabel:UILabel? {
        headersStack.arrangedSubviews.first(where: {
            $0.tag == 0 })?.subviews.first(where: {
                $0 is UILabel}) as? UILabel
    }
    
    var viewModel:EditorParametersVCViewModel?
    var parentVC: EditorViewController? {
        return parent as? EditorViewController
    }
    override var initialAnimation: Bool { return false}
    var viewType:EditorViewType {
        return parentVC?.viewModel?.viewType ?? .addingVideos
    }
    private var isSavePressed = false
    static var collectionViewSpace:CGPoint {
        let frame = UIApplication.shared.keyWindow?.frame ?? UIScreen.main.bounds
        return .init(x: frame.width / 2, y: 0)
    }
    
    private let setupUIAnimation = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)
    
    // MARK: - life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
        setUI(type: viewType)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }
    
    override func removeFromParent() {
        viewModel = nil
        collectionView.visibleCells.forEach {
            $0.removeFromSuperview()
        }
        assetStackView.removeFromSuperview()
        collectionView.removeFromSuperview()
        super.removeFromParent()
    }
    
    // MARK: - setup ui
    func setUI(type:EditorViewType, overlaySize:EditorOverlayContainerVC.OverlaySize = .small) {
        if let holder = DB.holder {
            self.performSetupUI(type:type, overlaySize:overlaySize, dbParameters:holder)
        } else {
            Task {
                let db = DB.db
                await MainActor.run {
                    self.performSetupUI(type:type, overlaySize:overlaySize, dbParameters:db)
                }
            }
        }
    }
    
    private func performSetupUI(type:EditorViewType, overlaySize:EditorOverlayContainerVC.OverlaySize = .small, dbParameters:DB.DataBase) {
        setupUIAnimation.stopAnimation(true)
        let dbHidden = dbParameters.movieParameters.editingMovie?.filtered ?? false
        print("parameterss: ", type)
        let filterPresented = parentVC?.mainEditorVC?.childVC?.navigationController?.viewControllers.count ?? 0
        print("efdwefr ", filterPresented)
        var isHidden = type == .addingVideos || overlaySize == .big || dbHidden
        if filterPresented != 1 {
            isHidden = true
        }
        let headerStacks = headersStack ?? .init()
        let canAnimate = (parentVC?.movieURL != nil) && (parentVC?.viewModel?.firstVideoAdded ?? false)
        assetStackView.arrangedSubviews.forEach { view in
            if !(view is UICollectionView) {
                if view.isHidden != isHidden {
                    if canAnimate {
                        print("setupUIAnimation tgerfwd")
                        UIView.animate(withDuration: 0.3) {
                            view.isHidden = isHidden
                        }
                    //    setupUIAnimation.addAnimations {
                    //    }
                    } else {
                        view.isHidden = isHidden
                    }
                }
                if let headerView = headerStacks.arrangedSubviews.first(where: {$0.tag == view.tag}) {
                    if headerView.isHidden != isHidden {
                        if canAnimate {
                            print("setupUIAnimation tgerfwd")
                         //   setupUIAnimation.addAnimations {
                            UIView.animate(withDuration: 0.3) {
                                headerView.isHidden = isHidden
                            }
                         //   }
                        } else {
                            headerView.isHidden = isHidden
                        }
                        
                    }
                }
            }
        }
        addVideoLabel?.text = type == .addingVideos ? "Add video" : "Edit/Export Video"
        setupUIAnimation.addAnimations { [weak self] in
            self?.collectionView.layer.cornerRadius(at: !isHidden ? .top : .all, value: 18)
        }
        setupUIAnimation.startAnimation()
    }
    
    private func togglePressScrollContent(_ enable:Bool) {
        headersStack.isUserInteractionEnabled = enable
        assetStackView.subviews.forEach {
            if let _ = $0 as? StackAssetAttachmentView {
                $0.isUserInteractionEnabled = enable
            }
        }
    }
    
    override var isAnimating: Bool {
        get {
            return parentVC?.isAnimating ?? false
        }
        set {
            parentVC?.isAnimating = newValue
        }
    }
    
    override func startRefreshing(canReturn: Bool = false, completion: (() -> ())? = nil) {
        parentVC?.startRefreshing(canReturn: canReturn, completion: completion)
    }
    
    override func endRefreshing(completion: (() -> ())? = nil) {
        parentVC?.endRefreshing(completion: completion)
    }
    
    // MARK: receive
    func assetChanged() {
        guard let viewModel,
              let editorModel = parentVC?.viewModel?.editorModel
        else { return}
        Task {
            await viewModel.assetChanged(parentVC?.viewModel?.editorModel.movie, editorModel: editorModel)
        }
    }
    
    func dataChanged(reloadTable:Bool) {
        if viewModel != nil {
            if reloadTable {
                collectionView.reloadData()
                parentVC?.previewImagesUpdated(image:viewModel?.tableData.first?.previews.first?.image)
            } else {
                updateAttachmantsStack()
                collectionView.reloadData()
                removeOverlays()
            }
        }
        print("gterfesdfregt ")
        
    }
    
    func changeDataWithoutReload(_ newData:AssetAttachmentProtocol?) {
        viewModel?.editingAsset = newData as? MovieAttachmentProtocol
        print("dataChangedasdadsd ")
    }
    
    // MARK: private
    var videoDuration:Double {
        return parentVC?.viewModel?.editorModel.movieDuration ?? 0
    }
    
    private func updateParentScroll(manual:Bool = false) {
        let max = scrollView.contentSize.width
        let percent = (scrollView.contentOffset.x + scrollView.contentInset.left) / (max - self.view.frame.width)
        parentVC?.seek(percent: scrollView.contentOffset.x <= max ? percent : 1, manual: manual)
    }
    
    private func removeOverlays() {
        parentVC?.mainEditorVC?.isHidden = true
        parentVC?.presentingOverlayVC?.removeFromParent()
    }
    
    // MARK: IBAction
    func scrollPercent(_ percent:CGFloat, selfScrolling:Bool = false) {
        if !(viewModel?.ignoreScroll ?? false) {
            viewModel?.manualScroll = true
            let max = scrollView.contentSize.width
            let scrollOffset = (max - self.view.frame.width) * percent
            if !selfScrolling {
                scrollView.contentOffset.x = (scrollOffset.isNormal && scrollOffset <= max ? scrollOffset : (percent <= 0.1 ? 0 : 1)) - scrollView.contentInset.left
            }
        }
    }
    
    @objc func leftHeaderPressed(_ sender:UITapGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        assetStackView.arrangedSubviews.forEach {
            if let view = $0 as? StackAssetAttachmentView,
               view.tag == sender.view?.tag
            {
                view.addEmptyPressed()
                return
            }
        }
        if sender.view?.tag == 0 {
            parentVC?.addTrackPressed()
        }
    }
}

extension EditorParametersViewController {
    func scrollingEnded() {
        viewModel?.scrollViewDeclaring = false
        viewModel?.ignoreScroll = false
        updateParentScroll()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel?.ignoreScroll = true
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        viewModel?.scrollViewDeclaring = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !(viewModel?.scrollViewDeclaring ?? false) {
            scrollingEnded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingEnded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let editingView = viewModel?.editingView,
           let editingRowView = editingView as? AssetRawView
        {
            let positionInParent = parentVC?.view.convert(editingView.frame, to: editingView) ?? .zero
            parentVC?.presentingOverlayVC?.positionInScrollChanged(new: positionInParent, editingRawView: editingRowView)
        }
        if viewModel?.manualScroll ?? false {
            viewModel?.manualScroll = false
        } else {
            updateParentScroll()
        }
    }
}

extension EditorParametersViewController:EditorOverlayVCDelegate {
    var attachmentData: AssetAttachmentProtocol? {
        get {
            return viewModel?.editingAsset
        }
        set {
            viewModel?.editingAsset = newValue
        }
    }
    
    func uploadPressed(_ type: EditorOverlayContainerVCViewModel.UploadPressedType) {
        parentVC?.uploadFromPressed(type: type)
    }
    
    func overlayChangedAttachment(_ newData: AssetAttachmentProtocol?) {
        parentVC?.playerVC?.editingAttachmentView?.data = newData as? MovieAttachmentProtocol
        (viewModel?.editingView as? AssetRawView)?.udpateData(data: newData, totalVideoDuration: videoDuration)
        parentVC?.presentingOverlayVC?.attachmentData = newData
    }
    
    func overlayRemoved() {
        //     if !isSavePressed {
        parentVC?.playerVC?.editorOverlayRemoved()
        //   }
        (viewModel?.editingView as? AssetRawView)?.updateText(viewModel?.editingAssetHolder, totalVideoDuration: videoDuration)
        viewModel?.editingView = nil
        assetStackView.subviews.forEach {
            if let view = $0 as? StackAssetAttachmentView {
                view.deselectAll()
            }
        }
        togglePressScrollContent(true)
    }
    
    func addAttachmentPressed(_ attachmentData: AssetAttachmentProtocol?) {
        isSavePressed = true
        Task {
            self.viewModel?.removeEditedAssetDB()
            await MainActor.run {
                self.parentVC?.addAttachmentPressed(attachmentData)
            }
        }
    }
}

extension EditorParametersViewController:AssetAttachmentViewDelegate {
    func attachmentPanChanged(view: AssetRawView?) {
        let x = view?.xConstraint?.constant ?? 0
        let total = (view?.superview?.frame ?? .zero).width
        let startPercent = x / total
        let durationPercent = (view?.frame.width ?? 0) / total
        print(startPercent, "startPercent ")
        print(durationPercent, " durationPercent")
        viewModel?.editingAsset?.time = .with({
            $0.start = startPercent
            $0.duration = durationPercent
        })
        if let view = viewModel?.editingView as? AssetRawView {
            view.updatePlayPercent(startPercent, totalDuration: videoDuration)
        }
        
    }
    
    func attachmentSelected(_ data: AssetAttachmentProtocol?, view:UIView?) {
        guard let parent = parentVC else {
            return
        }
        togglePressScrollContent(false)
        removeOverlays()
        viewModel?.editingAssetHolder = data
        viewModel?.editingAsset = data
        viewModel?.editingView = view
        parent.playerVC?.pause()
        self.parentVC?.playerVC?.editingAttachmentPressed(data)
        self.coordinator?.presentOverlay(parentVC: parent, stickToView: view ?? self.view, attachmentData: data, delegate: self)
    }
    
    var vc: UIViewController {
        return self
    }
}


extension EditorParametersViewController {
    static func configure() -> EditorParametersViewController {
        let vc = UIStoryboard(name: "EditorParameters", bundle: nil).instantiateViewController(withIdentifier: "AssetParametersViewController") as? EditorParametersViewController ?? .init()
        return vc
    }
}
