//
//  EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class EditorOverlayContainerVC: SuperVC {
    
   // @IBOutlet weak var containerView: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenType?.screenTitle
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleNavigationHidden()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.parentVC?.updateMainConstraints(viewController: self)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needTextField {
            parentVC?.view.textFieldBottomConstraint(stickyView: self.view, constant: 10)
        }
        toggleNavigationHidden(animated: false)
        collectionView.reloadData()
        collectionView.reloadInputViews()
    }
    
    private func toggleNavigationHidden(animated:Bool = true) {
        let hidden = (self.navigationController?.viewControllers.count ?? 0) <= 1
        self.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
    
    func updateData(_ collectionData:[EditorOverlayVC.OverlayCollectionData]) {
        self.collectionData = collectionData
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
fileprivate extension EditorOverlayContainerVC {
    func setupUI() {
        //view.backgroundColor = (navigationController?.viewControllers.count == 1) ? (parentVC?.view.backgroundColor ?? .clear) : .type(.secondaryBackground)
        view.backgroundColor = (parentVC?.view.backgroundColor ?? .clear)
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
//        primatyViews.forEach({
//            $0.superview?.isHidden = true
//        })
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
            
            if parentVC?.attachmentData?.attachmentType != nil && collectionData.count == 0 {
                viewModel?.uploadPressed = { [weak self] in
                    self?.parentVC?.attachmentDelegate?.uploadPressed($0)
                }
                viewModel?.assetDataHolder = parentVC?.attachmentData
                collectionData = viewModel?.getCollectionData ?? []
            } else if collectionData.count == 0 {
                collectionData = parentVC?.data?.collectionData ?? []
            }
        }
        print(collectionData, " tgerfrgthju6" , screenType)

        collectionView.delegate = self
        collectionView.dataSource = self
        if tableData.count != 0 {
            tableView.delegate = self
            tableView.dataSource = self
           // addChild(child: SelectionTableViewController.configure(), toView: containerView)
        }
        
        reloadData()
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
    
    private func reloadData() {
        collectionView.superview?.isHidden = collectionData.count == 0
        collectionView.reloadData()
      //  collectionView.reloadInputViews()
        print(tableData.count, " gerfweadw")
        print(collectionData.count, " gtefrdw")
        tableView.superview?.isHidden = tableData.count == 0
        tableView.reloadData()
    }
}

extension EditorOverlayContainerVC:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.textfieldEditing = false
        parentVC?.updateMainConstraints(viewController: self)
        collectionView.reloadSections(.init(integer: 1))
    //    collectionView.reloadInputViews()
        collectionView.reloadData()
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
