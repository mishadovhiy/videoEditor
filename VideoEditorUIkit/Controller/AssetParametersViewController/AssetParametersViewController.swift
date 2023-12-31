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
//        let t = UILabel()
//        t.text = "egrfew"
//        testRowView.addSubview(t)
//        t.addConstaits([.left:10, .top:50, .right:0, .height:20], superView: testRowView)
//        t.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }
    
}

//MARK: loadUI
fileprivate extension AssetParametersViewController {
    func loadUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AssetHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AssetHeaderCell.reuseIdentifier)
        //    collectionView.addConstaits([.width:1000], superView: self.view)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets.zero
        }
        collectionView.addConstaits([.width:2000], superView: self.view)
        loadAttachmentsSceletView()
    }
    
    func loadAttachmentsSceletView() {
        let data:[[MovieAttachmentProtocol]] = [assetData.megia, assetData.text, assetData.songs]
        assetStackView.backgroundColor = .black
        data.forEach({
            AssetAttachmentView.create($0, delegate: self, to: assetStackView)
        })
    }
}

extension AssetParametersViewController:AssetAttachmentViewDelegate {
    func attachmentSelected(_ data: MovieAttachmentProtocol?) {
        
    }
    
    var vc: UIViewController {
        return self
    }
    
    
}


//MARK: collationView
extension AssetParametersViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1//tableData[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath) as! AssetPreviewCell
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.green.cgColor
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AssetHeaderCell.reuseIdentifier, for: indexPath) as? AssetHeaderCell else {
            fatalError("Unable to dequeue header")
        }
        
        // Configure the header view (e.g., set label text based on section, etc.)
        headerView.label.text = "Section \(indexPath.section) Header"
        headerView.backgroundColor = .clear
        return headerView
    }
}

extension AssetParametersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: tableData[indexPath.section].duration, height: 50)
    }
    
}


extension AssetParametersViewController {
    static func configure() -> AssetParametersViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssetParametersViewController") as? AssetParametersViewController ?? .init()
        return vc
    }
}
