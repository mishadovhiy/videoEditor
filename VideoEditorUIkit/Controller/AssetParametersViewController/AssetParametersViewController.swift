//
//  TestCollectionView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 30.12.2023.
//

import UIKit
import AVFoundation

class AssetParametersViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetStackView: UIStackView!
    
    var viewModel:AssetParametersViewControllerViewModel?
    private var parentVC: EditorViewController? {
        return parent as? EditorViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }
    
    func assetChanged() {
        guard let viewModel else { return}
        Task {
            await viewModel.assetChanged(parentVC?.viewModel.movie)
        }
    }
    
    func dataChanged() {
        if view.superview != nil {
            updateAttachmantsStack()
            collectionView.reloadData()
        }
    }
    
    func scrollPercent(_ percent:CGFloat) {
        if !(viewModel?.ignoreScroll ?? false) {
            viewModel?.manualScroll = true
            let scrollOffset = (scrollView.contentSize.width - self.view.frame.width) * percent
            scrollView.contentOffset.x = scrollOffset.isNormal ? scrollOffset : 0
        }
    }
    
    func updateParentScroll() {
        let percent = scrollView.contentOffset.x / (scrollView.contentSize.width - view.frame.width)
        parentVC?.seek(percent: percent)
    }
}


extension AssetParametersViewController {
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
        if viewModel?.manualScroll ?? false {
            viewModel?.manualScroll = false
        } else {
            updateParentScroll()
        }
    }
}


extension AssetParametersViewController:AssetAttachmentViewDelegate {
    func attachmentSelected(_ data: MovieAttachmentProtocol?) {
        print(data, " rgterfreg")
    }
    
    var vc: UIViewController {
        return self
    }
}


extension AssetParametersViewController {
    static func configure() -> AssetParametersViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssetParametersViewController") as? AssetParametersViewController ?? .init()
        return vc
    }
}
