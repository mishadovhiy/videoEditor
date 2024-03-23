//
//  UICollectionViewDelegate_AssetParametersVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

//MARK: collationView
extension EditorParametersViewController:UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.tableData.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.tableData[section].previews.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath) as! AssetPreviewCell
        cell.set(time: viewModel?.tableData[indexPath.section].previews[indexPath.row].time ?? 0, asset: self.parentVC?.playerVC?.movie)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parentVC?.addTrackPressed()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AssetHeaderCell.reuseIdentifier, for: indexPath) as? AssetHeaderCell else {
            fatalError("Unable to dequeue header")
        }
        headerView.set(title: "Section \(indexPath.section) Header")
        headerView.backgroundColor = .clear
        return headerView
    }
}

extension EditorParametersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 1, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: MovieGeneralParameterList.AssetsData.cellWidth, height: collectionView.frame.height <= 0 ? 50 : collectionView.frame.height)
    }
}
