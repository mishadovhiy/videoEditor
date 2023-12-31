//
//  UICollectionViewDelegate_AssetParametersVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

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
