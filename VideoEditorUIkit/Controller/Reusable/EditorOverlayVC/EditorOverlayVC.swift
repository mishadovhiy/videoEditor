//
//  EditingOvarlayVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

protocol EditorOverlayVCDelegate {
    func addAttachmentPressed(_ attachmentData:AssetAttachmentProtocol?)
    func overlayChangedAttachment(_ newData:AssetAttachmentProtocol?)
    func overlayRemoved()
    func uploadPressed(_ type:EditorOverlayContainerVCViewModel.UploadPressedType)->()
    var attachmentData:AssetAttachmentProtocol? { get set }
}

class EditorOverlayVC: SuperVC {

    private var selectionIndicatorView:UIView? {
        return view.subviews.first(where: {$0.layer.name == "SelectionIndicatorView"})
    }
    @IBOutlet var actionButtons: [BaseButton]!

    var isPopup:Bool = false
    static let editingLayerName = "isEmptyView"
    var isEditingAttachment:Bool = false
    var data:ToOverlayData?
    var canSetHidden:Bool = true {
        didSet {
            actionButtons.forEach({
                $0.alpha = canSetHidden ? 1 : 0
            })
            if !canSetHidden && isHidden {
                isHidden = false
            }
        }
    }
    var attachmentData:AssetAttachmentProtocol? {
        get {
            return attachmentDelegate?.attachmentData
        }
        set {
            attachmentDelegate?.attachmentData = newValue
            dataChangedUI()
        }
    }
    var attachmentDelegate:EditorOverlayVCDelegate?
    override var initialAnimation: Bool { return false}
    var overlaySizeChanged:((_ newSize:EditorOverlayContainerVC.OverlaySize)->())?
    var textColor:UIColor {
        if (view.backgroundColor?.isLight ?? false) {
            return .type(.black)
        } else {
            return .type(isPopup || attachmentData != nil ? .white : .greyText)
        }
    }
    var childVC:EditorOverlayContainerVC? {
        return (children.first(where: {
            $0 is UINavigationController
        }) as? UINavigationController)?.viewControllers.first as? EditorOverlayContainerVC
    }
    
    private let isHiddenAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    private let appearenceAnimation = UIViewPropertyAnimator(duration: 0.39, curve: .easeInOut)
    let updateConstraintAnimation = UIViewPropertyAnimator(duration: 0.34, curve: .easeIn)
    
    // MARK: - Life-Cycle
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if view.superview == nil {
            return
        }
        setupUI()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigation = children.first(where: {$0 is UINavigationController}) as? UINavigationController {
            if navigation.delegate == nil {
                navigation.delegate = self
                navigation.setNavigationBarHidden(true, animated: true)
            }
        }
        if !isPopup {
            primaryConstraints(.small).forEach { constraint in
                if self.view.constraints.contains(where: {$0.identifier != constraint.value.1}) {
                    view.addConstaits([constraint.key:constraint.value])
                }
            }
        } else {
            childVC?.navigationController?.navigationBar.tintColor = .white
        }
    }
    
    override func removeFromParent() {
        self.attachmentDelegate?.overlayRemoved()
        self.attachmentData = nil
        view.endEditing(true)
        animateShow(show: false) {
            self.attachmentDelegate = nil
            self.view.constraints.forEach {
                self.view.removeConstraint($0)
            }
            self.view.superview?.constraints.forEach({
                if $0.firstItem as? NSObject == self || $0.secondItem as? NSObject == self {
                    self.view.superview?.removeConstraint($0)
                }
            })
            self.view.removeFromSuperview()
            super.removeFromParent()
        }
    }
    
    public func positionInScrollChanged(new position:CGRect, editingRawView:UIView) {
        let spaces = EditorParametersViewController.collectionViewSpace
        let newAlpha:Float = (editingRawView.frame.minX - (spaces.x + spaces.y)) >= position.minX ? 0 : 1
        if selectionIndicatorView?.layer.opacity ?? 0 != newAlpha {
            self.selectionIndicatorView?.layer.animationTransition(0.19)
            self.selectionIndicatorView?.layer.opacity = newAlpha
        }
    }
    
    /// data: set nil and call before updating AttachmentProtocol
    func updateData(_ data:[OverlayCollectionData]?) {
        if childVC?.navigationController?.viewControllers.count ?? 0 == 1 {
            childVC?.updateData(data)
        }
    }
    
    func childChangedData(_ attachmentData:AssetAttachmentProtocol?) {
        self.attachmentData = attachmentData
        attachmentDelegate?.overlayChangedAttachment(attachmentData)
    }
    
    var isHidden:Bool {
        get {
            self.view.superview?.isHidden ?? false
        }
        set {
 //           isHiddenAnimation.stopAnimation(true)
            let hide = canSetHidden ? newValue : false
            if view.superview?.isHidden ?? false != hide {
                self.audioBox?.vibrate()
                print("isHiddenAnimation tgerfwd")
           //     isHiddenAnimation.addAnimations {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.superview?.isHidden = hide
                }) { _ in
                    if !hide {
                        self.childVC?.updateUI(force: true)
                    }
                    if hide {
                        self.childVC?.navigationController?.popToRootViewController(animated: true)
                        
                    }
                    //        self.childVC?.view.layoutIfNeeded()

                }
           //     }
            }
            if hide {
                print("isHiddenAnimation tgerfwd")

        //        isHiddenAnimation.addAnimations({
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.alpha = 0
                }) { _ in
                    self.view.alpha = 1
                }
          //      })
          //      isHiddenAnimation.addCompletion {_ in
             //       self.view.alpha = 1
            //    }
            }
            
       //     isHiddenAnimation.addCompletion {_ in
                
        //    }
        //    isHiddenAnimation.startAnimation()
        }
    }
    
    func toggleNavigationController(appeared viewController:UIViewController?, countVC:Bool = true) {
        updateMainConstraints(viewController: viewController)
        let vcCount = (viewController?.navigationController?.viewControllers.count ?? 0) == 1
        let hidden = vcCount//countVC ? vcCount : viewController == childVC
        print(hidden, " hefrde")
        viewController?.navigationController?.setNavigationBarHidden(hidden, animated: true)
    }
    
    func performAddAttachment() {
        if attachmentDelegate != nil {
            attachmentDelegate?.addAttachmentPressed(attachmentData)
        }
        if isPopup  {
            dismiss(animated: true)
        } else {
            data?.donePressed?()
        }
    }
    
    // MARK: - IBAction
    @IBAction func addPressed(_ sender: UIButton) {
        performAddAttachment()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        if isPopup {
            removeFromParent()
        } else {
            data?.closePressed?()
        }
    }
}

fileprivate extension EditorOverlayVC {
    func dataChangedUI() {
        self.actionButtons.forEach {
            $0.layer.animationTransition(0.17)
            $0.setTitleColor(self.textColor, for: .normal)
            $0.tintColor = self.textColor
        }
        let plusButton = self.actionButtons.first(where: {$0.tag == 1})

        UIView.animate(withDuration: 0.2) {
            plusButton?.backgroundColor = (self.attachmentData?.trackColor ?? self.view.backgroundColor)?.darker().withAlphaComponent(0.2)
            self.setBackground()
        }
    }
    
    final func animateShow(show:Bool, completion:(()->())? = nil) {
        appearenceAnimation.stopAnimation(true)
        appearenceAnimation.addAnimations { [ weak self] in
            self?.view.alpha = show ? 1 : 0
            self?.view.layer.zoom(value: !show ? 1.2 : 1)
        }
        if show {
            self.view.layer.zoom(value: 0.6)
        }
        appearenceAnimation.addCompletion { _ in
            completion?()
            if show {
                self.dataChangedUI()
            }
        }
        appearenceAnimation.startAnimation()
    }
}

extension EditorOverlayVC:UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
        toggleNavigationController(appeared: viewController)
    }
}

extension EditorOverlayVC {
    private static func configure() -> EditorOverlayVC {
        let vc = UIStoryboard(name: "EditorOverlay", bundle: nil).instantiateViewController(withIdentifier: "EditorOverlayVC") as? EditorOverlayVC ?? .init()
        return vc
    }
    
    static func configure(data:ToOverlayData) -> EditorOverlayVC {
        let vc = EditorOverlayVC.configure()
        vc.data = data
        return vc
    }
    
    static func configure(attechemntData:AssetAttachmentProtocol?,
                          delegate:EditorOverlayVCDelegate?) -> EditorOverlayVC {
        let vc = EditorOverlayVC.configure()
        vc.view.layer.name = String(describing: EditorOverlayVC.self)
        vc.attachmentData = attechemntData
        vc.attachmentDelegate = delegate
        vc.view.alpha = 0
        return vc
    }
    
    static func addOverlayToParent(_ parent:UIViewController,
                            bottomView:UIView,
                            attachmentData:AssetAttachmentProtocol?,
                            delegate:EditorOverlayVCDelegate?
    ) {
        let vc = EditorOverlayVC.configure(attechemntData: attachmentData, delegate: delegate)
        vc.isEditingAttachment = bottomView.layer.name != self.editingLayerName
        vc.isPopup = true
        parent.addChild(child: vc, constaits: vc.primaryConstraints(.small))
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.bottomAnchor, constant: attachmentData?.attachmentType == .text ? -26 : -20).isActive = true
        vc.loadSeectionIndocator(bottomView: bottomView, parent: parent)
        vc.animateShow(show: true)
        AppDelegate.shared?.audioBox.vibrate()
    }
}
