//
//  TestCollectionView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 30.12.2023.
//

import UIKit

class AssetParametersViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetStackView: UIStackView!
    @IBOutlet weak var testRowView: UIView!

    var assetData:MovieGeneralParameterList = .test
    var tableData:[MovieGeneralParameterList.AssetsData] {
        return assetData.asstes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
}


extension AssetParametersViewController {
    static func configure() -> AssetParametersViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssetParametersViewController") as? AssetParametersViewController ?? .init()
        return vc
    }
}
