//
//  EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class EditorOverlayContainerVC: SuperVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var collectionView:UICollectionView!
    var primatyViews:[UIView] {
        [tableView]
    }
    override var initialAnimation: Bool { return false}
    var initialTableData:[EditorOverlayVC.ToOverlayData.AttachmentOverlayType]?
    var tableData:[EditorOverlayVC.ToOverlayData.AttachmentOverlayType] {
        return screenType?.tableData ?? (initialTableData ?? [])
    }
    var screenType:EditorOverlayVC.ToOverlayData?
    var viewModel:EditorOverlayContainerVCViewModel?
    var collectionData:[EditorOverlayVC.OverlayCollectionData] = []
    var canReloadSubviews:Bool = true

    var needTextField:Bool {
        return parentVC?.data?.needTextField ?? (viewModel?.type == .text) && ((navigationController?.viewControllers.count ?? 0) == 1)
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
    
    var parentVCOptional:EditorOverlayVC? {
        if navigationController?.viewControllers.count ?? 0 == 1 {
            return parentVC
        } else {
            return nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if canReloadSubviews {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenType?.screenTitle
        setupUI()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    func updateData(_ collectionData:[EditorOverlayVC.OverlayCollectionData]?) {
        if view.superview == nil {
            return
        }
        viewModel?.assetDataHolder = parentVCOptional?.attachmentData
        self.collectionData = collectionData ?? viewModel?.getCollectionData ?? []
        reloadData()
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
extension EditorOverlayContainerVC {
    private func setupUI() {
        view.backgroundColor = (parentVC?.view.backgroundColor ?? .clear)
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
        switch screenType?.attachmentType {
        case .floatRange(_), .switch(_):
            if let type = screenType?.attachmentType {
                screenType?.tableData = [type]
            }
        case .color(let colorAction):
            viewModel = .init()
            collectionData = (viewModel?.colorCollectionData ?? []).compactMap({ color in
                return .init(title: color.title, didSelect: {
                    colorAction.didSelect(color.backgroundColor ?? .red)
                }, backgroundColor:color.backgroundColor ?? .clear)
            })
        default:
            let needViewModel = tableData.count != 0 || parentVCOptional?.attachmentData?.attachmentType != nil
            if needViewModel {
                let attachment = parentVCOptional?.attachmentData?.attachmentType
                viewModel = .init(type:attachment, didPress: { [weak self] pressType in
                    guard let self else { return }
                    switch pressType {
                    case .delete:
                        print("parent delete not implemented")
                    case .reload:
                        updateData(nil)
                    case .assetChanged(let changed):
                        let oldData = changed(self.parentVC?.attachmentData ?? TextAttachmentDB.demo)
                        self.parentVC?.childChangedData(oldData)
                        
                    case .upload(let upload):
                        self.parentVC?.attachmentDelegate?.uploadPressed(upload)
                    }
                })
            } else {
                viewModel = .init()
            }
            
            if parentVCOptional?.attachmentData?.attachmentType != nil && collectionData.count == 0 {
                viewModel?.isEditing = parentVC?.isEditingAttachment ?? false
                viewModel?.assetDataHolder = parentVC?.attachmentData
                collectionData = viewModel?.getCollectionData ?? []
            } else if collectionData.count == 0 {
                collectionData = parentVCOptional?.data?.collectionData ?? []
            }
        }
        print(collectionData, " tgerfrgthju6" , screenType)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        if tableData.count != 0 {
            tableView.delegate = self
            tableView.dataSource = self
        }
        
        reloadData()
        if !needTextField {
            collectionView.contentInset.left = view.frame.width / 9
        }
    }
    
    private func reloadData() {
        collectionView.superview?.isHidden = collectionData.count == 0
        collectionView.reloadData()
        //  collectionView.reloadInputViews()
        print(tableData.count, " gerfweadw")
        print(collectionData.count, " gtefrdw")
        tableView.superview?.isHidden = tableData.count == 0
        tableView.reloadData()
    }
    
    func updateUI() {
        if needTextField {
            parentVC?.view.textFieldBottomConstraint(stickyView: self.view, constant: 10)
        }
        parentVC?.toggleNavigationController(appeared: self, countVC: false)
        collectionView.reloadData()
        collectionView.reloadInputViews()
        if parentVC?.isPopup ?? false {
            navigationController?.navigationBar.tintColor = parentVC?.textColor
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: parentVC?.textColor ?? .red]
        }
        
    }
}

extension EditorOverlayContainerVC:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        canReloadSubviews = false
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.textfieldEditing = false
        parentVC?.updateMainConstraints(viewController: self)
        collectionView.reloadSections(.init(integer: 1))
        collectionView.reloadData()
        canReloadSubviews = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel?.textfieldEditing = true
        parentVC?.updateMainConstraints(viewController: self, textFieldEditing: true)
        collectionView.reloadSections(.init(integer: 1))
      //  collectionView.reloadInputViews()
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
