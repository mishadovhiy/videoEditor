//
//  EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class EditorOverlayContainerVC: UIViewController {

    @IBOutlet private weak var textField:UITextField!
    @IBOutlet private weak var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

fileprivate extension EditorOverlayContainerVC {
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        textField.delegate = self
    }
}

extension EditorOverlayContainerVC:UITextFieldDelegate {
    
}

