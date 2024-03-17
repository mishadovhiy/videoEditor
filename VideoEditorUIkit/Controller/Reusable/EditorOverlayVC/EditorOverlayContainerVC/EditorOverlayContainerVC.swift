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
    @IBOutlet private weak var collectionView:UICollectionView!
    var primatyViews:[UIView] {
        [sliderView, containerView]
    }
    override var initialAnimation: Bool { return false}
    var screenType:EditorOverlayVC.ToOverlayData?
    var viewModel:EditorOverlayContainerVCViewModel?
    var collectionData:[EditorOverlayVC.OverlayCollectionData] = []
    
    var needTextField:Bool {
        return parentVC?.data?.needTextField ?? (viewModel?.type == .text)
    }
    
    var screenSize:OverlaySize? {
        switch screenType?.attachmentType {
        case .color(_):
            return .middle
        default:
            if let type = screenType?.screenHeight {
                return type
            }
            if let data = parentVC?.data?.screenHeight {
                return data
            }
            return nil
        }
    }
    
    var parentVC:EditorOverlayVC? {
        return navigationController?.parent as? EditorOverlayVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenType?.screenTitle
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleNavigationHidden()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needTextField {
            parent?.view.textFieldBottomConstraint(stickyView: self.view, constant: 10)
            collectionView.reloadInputViews()
        }
        toggleNavigationHidden(animated: false)
        self.parentVC?.updateMainConstraints(viewController: self)
    }
    
    private func toggleNavigationHidden(animated:Bool = true) {
        let hidden = (self.navigationController?.viewControllers.count ?? 0) <= 1
        self.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
    
    func updateData(_ collectionData:[EditorOverlayVC.OverlayCollectionData]) {
        self.collectionData = collectionData
        collectionView.reloadData()
        collectionView.isHidden = collectionData.isEmpty
    }
    
    @objc func textFieldDidChanged(_ sender:UITextField) {
        var data = parentVC?.attachmentData
        data?.assetName = sender.text
        if let data {
            parentVC?.childChangedData(data)
        }
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
        //view.backgroundColor = (navigationController?.viewControllers.count == 1) ? (parentVC?.view.backgroundColor ?? .clear) : .type(.secondaryBackground)
        view.backgroundColor = (parentVC?.view.backgroundColor ?? .clear)
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
        primatyViews.forEach({
            if $0 == self.containerView {
                $0.isHidden = true
            } else {
                $0.superview?.isHidden = true
            }
        })
        switch screenType?.attachmentType {
        case .floatRange(_):
            sliderView.superview?.isHidden = false
            sliderView.addTarget(self, action: #selector(sliderChanged(_:)), for: .touchUpInside)
        case .color(let colorAction):
            containerView.isHidden = false
            viewModel = .init()
            collectionData = (viewModel?.colorCollectionData ?? []).compactMap({ color in
                return .init(title: color.title, didSelect: {
                    colorAction.didSelect(color.backgroundColor ?? .red)
                }, backgroundColor:color.backgroundColor ?? .red)
            })
        default:
            if let attachment = parentVC?.attachmentData?.attachmentType {
                viewModel = .init(type: attachment, assetChanged: { didChange in
                    if let value = self.parentVC?.attachmentData  as? TextAttachmentDB {
                        var oldData = self.parentVC?.attachmentData
                        oldData = didChange(value)
                        if let oldData {
                            self.parentVC?.childChangedData(oldData)
                        }
                    }
                })
            } else {
                viewModel = .init()
            }
            
            if parentVC?.attachmentData?.attachmentType != nil && collectionData.isEmpty {
                collectionData = viewModel?.getCollectionData ?? []
            } else if collectionData.isEmpty {
                collectionData = parentVC?.data?.collectionData ?? []
            }
            print(collectionData, " tgerfrgthju6")
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = collectionData.isEmpty
        if !needTextField {
            collectionView.contentInset.left = view.frame.width / 9
        }
    }
    
    @objc private func sliderChanged(_ sender:UISlider) {
        switch screenType?.attachmentType {
        case .floatRange(let floatType):
            floatType.didSelect(CGFloat(sender.value))
        default: return
        }
    }
}

extension EditorOverlayContainerVC:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.textfieldEditing = false
        parentVC?.updateMainConstraints(viewController: self)
        collectionView.reloadSections(.init(integer: 1))
        collectionView.reloadInputViews()
        collectionView.reloadData()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel?.textfieldEditing = true
        parentVC?.updateMainConstraints(viewController: self, textFieldEditing: true)
        collectionView.reloadSections(.init(integer: 1))
        collectionView.reloadInputViews()
    }
}

extension EditorOverlayContainerVC:UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        switch screenType?.attachmentType {
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
