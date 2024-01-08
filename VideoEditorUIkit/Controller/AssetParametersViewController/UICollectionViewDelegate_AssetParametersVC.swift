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
        return tableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("fads count", tableData[section].previews.count)
        print("erfd dur ", tableData[section].duration)
        return tableData[section].previews.count
        //Int(tableData[section].duration / 15)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath) as! AssetPreviewCell
        var i = -1
        var data:[MovieGeneralParameterList.AssetsData] = []
        tableData.forEach {
            i += 1
            if i <= (indexPath.section - 1) {
                data.append($0)
            }
        }
        let count = data.reduce(0) { partialResult, data in
            return partialResult + data.previews.count
        }
        let secs = (CGFloat(count + (indexPath.row + 1))) / AssetParametersViewController.durationWidthMultiplier
//        if secs == CGFloat(Int(secs)) {
            //     cell.secondLabel.text = "\(secs)"
//
//        } else {
//            cell.secondLabel.text = ""
//
//        }
        cell.secondLabel.text = ""
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
        let value = tableData[section].duration / 15
        let width = value - CGFloat(Int(value))
        return CGSize(width: 1, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = tableData[indexPath.section].duration / CGFloat(tableData[indexPath.section].previews.count)
  //      let width = (tableData[indexPath.section].duration * AssetParametersViewController.durationWidthMultiplier) / CGFloat(tableData[indexPath.section].previews.count)
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
}
