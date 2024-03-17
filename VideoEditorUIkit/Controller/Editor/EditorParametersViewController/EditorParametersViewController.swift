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
    private var parentVC: EditorViewController? {
        return parent as? EditorViewController
    }
    override var initialAnimation: Bool { return false}
    var viewType:EditorViewType {
        return parentVC?.viewModel?.viewType ?? .addingVideos
    }
    static var collectionViewSpace:CGPoint {
        let frame = UIApplication.shared.keyWindow?.frame ?? UIScreen.main.bounds
        return .init(x: frame.width / 2, y: frame.width / 2)
    }
    
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
        collectionView.removeFromSuperview()
        super.removeFromParent()
    }
    
    // MARK: - setup ui
    func setUI(type:EditorViewType, overlaySize:EditorOverlayContainerVC.OverlaySize = .small) {
        let isHidden = type == .addingVideos || overlaySize == .big
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
        assetStackView.arrangedSubviews.forEach { view in
            if !(view is UICollectionView) {
                animation.addAnimations {[weak self] in
                    view.isHidden = isHidden
                    if let headerView = self?.headersStack.arrangedSubviews.first(where: {$0.tag == view.tag}) {
                        headerView.isHidden = isHidden
                    }
                }
            }
        }
        addVideoLabel?.text = type == .addingVideos ? "Add video" : "Edit Video"
        animation.addAnimations { [weak self] in
            self?.collectionView.layer.cornerRadius(at: !isHidden ? .top : .all, value: 18)
        }
        animation.startAnimation()
    }
    
    private func togglePressScrollContent(_ enable:Bool) {
        headersStack.isUserInteractionEnabled = enable
        assetStackView.subviews.forEach {
            if let _ = $0 as? StackAssetAttachmentView {
                $0.isUserInteractionEnabled = enable
            }
        }
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
    }
    
    func changeDataWithoutReload(_ newData:AssetAttachmentProtocol?) {
        viewModel?.editingAsset = newData as? MovieAttachmentProtocol
    }
    
    // MARK: private
    private func updateParentScroll() {
        let percent = (scrollView.contentOffset.x + scrollView.contentInset.left) / (scrollView.contentSize.width - view.frame.width)
        parentVC?.seek(percent: percent)
    }
    
    private func removeOverlays() {
        parentVC?.presentingOverlayVC?.removeFromParent()
    }
    
    // MARK: IBAction
    func scrollPercent(_ percent:CGFloat) {
        if !(viewModel?.ignoreScroll ?? false) {
            viewModel?.manualScroll = true
            let scrollOffset = ((scrollView.contentSize.width + scrollView.contentInset.left) - self.view.frame.width) * percent
            scrollView.contentOffset.x = (scrollOffset.isNormal ? scrollOffset : 0) - scrollView.contentInset.left
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
    func overlayChangedAttachment(_ newData: AssetAttachmentProtocol?) {
        parentVC?.playerVC?.editingAttachmentView?.data = newData as? MovieAttachmentProtocol
    }
    
    func overlayRemoved() {
        parentVC?.playerVC?.editorOverlayRemoved()
        viewModel?.editingView = nil
        assetStackView.subviews.forEach {
            if let view = $0 as? StackAssetAttachmentView {
                view.deselectAll()
            }
        }
        togglePressScrollContent(true)
    }
    
    func addAttachmentPressed(_ attachmentData: AssetAttachmentProtocol?) {
        parentVC?.playerVC?.startRefreshing(completion: {
            Task {
                self.viewModel?.removeEditedAssetDB()
                await MainActor.run {
                    self.parentVC?.addAttachmentPressed(self.viewModel?.attachmentData(attachmentData: attachmentData) ?? attachmentData)
                }
            }
        })
    }
}

extension EditorParametersViewController:AssetAttachmentViewDelegate {
    func attachmentPanChanged(view: AssetRawView?) {
        let converted = view?.superview?.convert(view?.frame ?? .zero, from: view ?? .init()) ?? .zero
        let total = view?.superview?.frame ?? .zero
        let startPercent = converted.minX / total.width
        let durationPercent = (view?.frame.width ?? 0) / total.width
        print(startPercent, "startPercent ")
        print(durationPercent, " durationPercent")
        viewModel?.editingAsset?.time = .with({
            $0.start = startPercent
            $0.duration = durationPercent
        })

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
