//
//  UICollectionView_EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

extension EditorOverlayContainerVC:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditorCollectionCell", for: indexPath) as! EditorCollectionCell
        cell.set(collectionData[indexPath.row], type: screenSize)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = collectionData[indexPath.row]
        if let didSelect = data.didSelect {
            didSelect()
        } else if let type = data.toOverlay {
            self.navigationController?.pushViewController(EditorOverlayContainerVC.configure(type: type, collectionData: type.collectionData), animated: true)
        }
    }    
}
