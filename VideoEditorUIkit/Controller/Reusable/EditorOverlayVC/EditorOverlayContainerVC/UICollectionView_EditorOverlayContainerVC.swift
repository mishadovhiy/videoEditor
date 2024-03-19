//
//  UICollectionView_EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

extension EditorOverlayContainerVC:UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return collectionData.count
        } else {
            return needTextField ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditorCollectionCell", for: indexPath) as! EditorCollectionCell
            cell.set(collectionData[indexPath.row], type: screenSize, textFieldEditing: viewModel?.textfieldEditing ?? false, textColor: parentVC?.textColor)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverlayTextFieldCell", for: indexPath) as! OverlayTextFieldCell
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
            cell.textField.text = parentVC?.attachmentData?.assetName == TextAttachmentDB.demo.assetName ? "" : parentVC?.attachmentData?.assetName
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section != 1 {
            return
        }
        let data = collectionData[indexPath.row]
        if let didSelect = data.didSelect {
            didSelect()
        } else if let type = data.toOverlay {
            self.navigationController?.pushViewController(EditorOverlayContainerVC.configure(type: type, collectionData: type.collectionData), animated: true)
        }
    }
}

extension EditorOverlayContainerVC:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewHeight = view.frame.height - (view.safeAreaInsets.bottom + view.safeAreaInsets.top)
        if indexPath.section == 0 {
            return .init(width: view.frame.width / 1.4, height: viewHeight)
        }
        var type = screenSize
        if viewModel?.textfieldEditing ?? false {
            type = .middle
        }
        print(view.frame.height, "gterfwdqas ", type)
        switch type {
        case .big:
            return .init(width: 150, height: viewHeight)
        default:
            let font = UIFont.systemFont(ofSize: CGFloat(12), weight: .bold)
            let textWidth = font.calculate(inWindth:view.frame.width, attributes:[.font:font], string: collectionData[indexPath.row].title).width
            print(textWidth, " efrwdesax")
            return .init(width: textWidth <= 80 ? 80 : textWidth, height: viewHeight)
        }
    }
}
