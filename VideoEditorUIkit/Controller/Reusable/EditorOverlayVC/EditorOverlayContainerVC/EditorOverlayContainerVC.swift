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
    
    private var parentVC:EditorOverlayVC? {
        return ((navigationController?.parent as? EditorOverlayVC)?.parent as? EditorViewController)?.children.first(where: {
            $0 is EditorOverlayVC
        }) as? EditorOverlayVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.view.textFieldBottomConstraint(stickyView: self.view)
    }
    
    @objc private func textFieldDidChanged(_ sender:UITextField) {
        parentVC?.attachmentData?.assetName = sender.text
    }
}

fileprivate extension EditorOverlayContainerVC {
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
}

