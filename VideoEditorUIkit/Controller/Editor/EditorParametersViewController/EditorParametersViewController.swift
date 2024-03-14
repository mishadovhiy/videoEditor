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
    
    var viewModel:ViewModelEditorParametersViewController?
    private var parentVC: EditorViewController? {
        return parent as? EditorViewController
    }
    override var initialAnimation: Bool { return false}
    var viewType:EditorViewType {
        return parentVC?.viewModel?.viewType ?? .addingVideos
    }
    static var collectionViewSpace:CGPoint {
        let screen = UIScreen.main.bounds
        return .init(x: screen.width / 2, y: screen.width / 2)
    }
    
    // MARK: - life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
        setUI(type: viewType)
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
    func setUI(type:EditorViewType) {
        assetStackView.arrangedSubviews.forEach {
            if !($0 is UICollectionView) {
                $0.alpha = type == .addingVideos ? 0 : 1
            }
        }
        addVideoLabel?.text = type == .addingVideos ? "Add video" : "Edit Video"
        if type == .editing {
            collectionView.layer.cornerRadius(at: .top, value: 18)
        } else {
            collectionView.layer.masksToBounds = true
            collectionView.layer.cornerRadius = 18
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
        viewModel?.editingAsset?.inMovieStart = startPercent
        viewModel?.editingAsset?.duration = durationPercent

    }
    
    func attachmentSelected(_ data: MovieAttachmentProtocol?, view:UIView?) {
        guard let parent = parentVC else {
            return
        }
        parent.playerVC?.pause()
        viewModel?.editingAssetHolder = data
        viewModel?.editingAsset = data
        viewModel?.editingView = view
        if let data {
            parentVC?.playerVC?.editingAttachmentPressed(data)
        }
        removeOverlays()
        EditorOverlayVC.addOverlayToParent(parent, bottomView: view ?? self.view, attachmentData: data, delegate: self)
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
