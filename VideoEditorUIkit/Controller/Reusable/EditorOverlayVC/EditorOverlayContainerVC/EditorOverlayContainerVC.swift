//
//  EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class EditorOverlayContainerVC: SuperVC {
    
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var textField:UITextField!
    @IBOutlet private weak var collectionView:UICollectionView!
    var primatyViews:[UIView] {
        [sliderView, containerView, textField]
    }
    override var initialAnimation: Bool { return false}
    var screenType:EditorOverlayVC.ToOverlayData?
    var viewModel:ViewModelEditorOverlayContainerVC?
    var collectionData:[EditorOverlayVC.OverlayCollectionData] = []
    
    var screenSize:OverlaySize? {
        switch screenType?.type {
        case .color(_):
            return .middle
        default:
            return nil
        }
    }
    
    private var parentVC:EditorOverlayVC? {
        return ((navigationController?.parent as? EditorOverlayVC)?.parent as? EditorViewController)?.children.first(where: {
            $0 is EditorOverlayVC
        }) as? EditorOverlayVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = screenType?.screenTitle
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.view.textFieldBottomConstraint(stickyView: self.view, constant: 10)
    }
    
    @objc private func textFieldDidChanged(_ sender:UITextField) {
        parentVC?.attachmentData?.assetName = sender.text
    }
}

extension EditorOverlayContainerVC {
    enum OverlaySize {
        case small
        case middle
        case big
    }
}

// MARK: - setupUI
fileprivate extension EditorOverlayContainerVC {
    func setupUI() {
        primatyViews.forEach({
            if $0 == self.containerView {
                $0.isHidden = true
            } else {
                $0.superview?.isHidden = true
            }
        })
        switch screenType?.type {
        case .floatRange(_):
            sliderView.superview?.isHidden = false
        case .color(let colorAction):
            containerView.isHidden = false
            viewModel = .init()
            collectionData = (viewModel?.colorCollectionData ?? []).compactMap({ color in
                return .init(title: color.title, didSelect: {
                    colorAction.didSelect(color.backgroundColor ?? .red)
                }, backgroundColor:color.backgroundColor ?? .red)
            })
        default:
            viewModel = .init(type: parentVC?.attachmentData?.attachmentType ?? .media, assetChanged: { didChange in
                if let value = self.parentVC?.attachmentData  as? TextAttachmentDB {
                    self.parentVC?.attachmentData = didChange(value)
                }
            })
            setupTF()
            if parentVC?.attachmentData?.attachmentType != nil && collectionData.isEmpty {
                collectionData = viewModel?.getCollectionData ?? []
            }
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = collectionData.isEmpty
    }
    
    func setupTF() {
        textField.delegate = self
        textField.superview?.isHidden = false
        textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
}

extension EditorOverlayContainerVC:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        parentVC?.updateMainConstraints(viewController: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        parentVC?.updateMainConstraints(viewController: self, textFieldEditing: true)
    }
}

extension EditorOverlayContainerVC:UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        switch screenType?.type {
        case .color(let selected):
            selected.didSelect(color)
        default:
            break
        }
    }
}

extension EditorOverlayContainerVC {
    static func configure(type:EditorOverlayVC.ToOverlayData?, collectionData:[EditorOverlayVC.OverlayCollectionData]) -> EditorOverlayContainerVC {
        let vc = UIStoryboard(name: "EditorOverlay", bundle: nil).instantiateViewController(identifier: "EditorOverlayContainerVC") as? EditorOverlayContainerVC
        vc?.screenType = type
        vc?.collectionData = collectionData
        return vc ?? .init()
    }
}
