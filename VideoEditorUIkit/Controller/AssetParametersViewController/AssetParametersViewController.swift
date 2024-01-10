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
    
    var assetData:MovieGeneralParameterList = .test
    static var rowsHeight:CGFloat = 20
    static let durationWidthMultiplier:CGFloat = 15
    var scrollViewDeclaring = false
    
    var tableData:[MovieGeneralParameterList.AssetsData] {
        return assetData.asstes
    }
    private var ignoreScroll:Bool = false
    
    var parentVC: EditorViewController? {
        return parent as? EditorViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    func scrollPercent(_ percent:CGFloat) {
        if !ignoreScroll {
            scrollView.contentOffset.x = (scrollView.contentSize.width - self.view.frame.width) * percent
            
        }
    }
}


extension AssetParametersViewController {
    func scrollingEnded() {
        scrollViewDeclaring = false
        ignoreScroll = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        ignoreScroll = true
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDeclaring = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !scrollViewDeclaring {
            scrollingEnded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingEnded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !ignoreScroll {
            return
        }
        let percent = scrollView.contentOffset.x / (scrollView.contentSize.width - view.frame.width)
        parentVC?.seek(percent: percent)
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
