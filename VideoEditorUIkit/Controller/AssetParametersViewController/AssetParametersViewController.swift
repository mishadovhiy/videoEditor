//
//  TestCollectionView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 30.12.2023.
//

import UIKit

class AssetParametersViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetStackView: UIStackView!
    
    var viewModel:AssetParametersViewControllerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    var parentVC: EditorViewController? {
        return parent as? EditorViewController
    }
    
    func scrollPercent(_ percent:CGFloat) {
        if !viewModel.ignoreScroll {
            scrollView.contentOffset.x = (scrollView.contentSize.width - self.view.frame.width) * percent
            
        }
    }
    
    func updateParenScroll() {
        let percent = scrollView.contentOffset.x / (scrollView.contentSize.width - view.frame.width)
        parentVC?.seek(percent: percent)
    }
}


extension AssetParametersViewController {
    func scrollingEnded() {
        viewModel.scrollViewDeclaring = false
        viewModel.ignoreScroll = false
        updateParenScroll()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.ignoreScroll = true
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        viewModel.scrollViewDeclaring = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !viewModel.scrollViewDeclaring {
            scrollingEnded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingEnded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !viewModel.ignoreScroll {
            return
        }
        updateParenScroll()
    }
}


extension AssetParametersViewController:AssetAttachmentViewDelegate {
    func attachmentSelected(_ data: MovieAttachmentProtocol?) {
        
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
