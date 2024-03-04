//
//  UICollectionViewDelegate_AssetParametersVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

//MARK: collationView
extension AssetParametersViewController:UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.tableData.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.tableData[section].previews.count ?? 0
        //Int(tableData[section].duration / 15)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath) as! AssetPreviewCell


        cell.secondLabel.text = ""
       // cell.secondLabel.text = indexPath.row != 0 ? "" : "\(viewModel?.tableData[indexPath.section].duration ?? 0)"
        if let data = viewModel?.tableData[indexPath.section].previews[indexPath.row].image {
            cell.previewImageView.image = .init(data: data)
        } else {
            cell.previewImageView.image = nil
        }
        cell.previewImageView.constraints.first(where: {$0.firstAttribute == .width})?.constant = MovieGeneralParameterList.AssetsData.cellWidth
        cell.previewImageView.layoutIfNeeded()
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
        return CGSize(width: 1, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: MovieGeneralParameterList.AssetsData.cellWidth, height: collectionView.frame.height)
    }
    
}
