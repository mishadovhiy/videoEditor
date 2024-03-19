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
}

class EditorOverlayVC: SuperVC {

    private var selectionIndicatorView:UIView? {
        return view.subviews.first(where: {$0.layer.name == "SelectionIndicatorView"})
    }
    @IBOutlet var actionButtons: [BaseButton]!
    
    var data:ToOverlayData?
    var attachmentData:AssetAttachmentProtocol?
    var attachmentDelegate:EditorOverlayVCDelegate?
    override var initialAnimation: Bool { return false}
    var overlaySizeChanged:((_ newSize:EditorOverlayContainerVC.OverlaySize)->())?
    private var childVC:EditorOverlayContainerVC? {
        return (children.first(where: {
            $0 is UINavigationController
        }) as? UINavigationController)?.topViewController as? EditorOverlayContainerVC
    }
    // MARK: - Life-Cycle
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        setupUI()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigation = children.first(where: {$0 is UINavigationController}) as? UINavigationController {
            navigation.delegate = self
            navigation.setNavigationBarHidden(true, animated: true)
        }
        if !(data?.isPopup ?? true) {
            primaryConstraints(.small).forEach { constraint in
                if self.view.constraints.contains(where: {$0.identifier != constraint.value.1}) {
                    view.addConstaits([constraint.key:constraint.value])
                }
            }
        }
    }
    
    override func removeFromParent() {
        if !(data?.isPopup ?? true) {
            return
        }
        attachmentDelegate?.overlayRemoved()
        attachmentData = nil
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
    
    func updateData(_ data:[OverlayCollectionData]) {
        childVC?.updateData(data)
    }
    
    func childChangedData(_ attachmentData:AssetAttachmentProtocol) {
        self.attachmentData = attachmentData
        attachmentDelegate?.overlayChangedAttachment(attachmentData)
    }
    
    var isHidden:Bool = false {
        didSet {
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.view.superview?.isHidden = self.isHidden
            }
            if isHidden {
                animation.addAnimations({
                    self.view.alpha = 0
                }, delayFactor: 0.18)
                animation.addCompletion {_ in
                    self.view.alpha = 1
                }
            }
            
            animation.startAnimation()
        }
    }
    
    // MARK: - IBAction
    @IBAction func addPressed(_ sender: UIButton) {
        if attachmentDelegate != nil {
            attachmentDelegate?.addAttachmentPressed(attachmentData)
        }
        if data?.isPopup ?? true  {
            removeFromParent()
        } else {
            data?.donePressed?()
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        if data?.isPopup ?? true {
            removeFromParent()
        } else {
            data?.closePressed?()
        }
    }
}

fileprivate extension EditorOverlayVC {
    func animateShow(show:Bool, completion:(()->())? = nil) {
        let animation = UIViewPropertyAnimator(duration: 0.19, curve: .easeInOut) {
            self.view.alpha = show ? 1 : 0
            self.view.layer.zoom(value: !show ? 1.2 : 1)
        }
        animation.addCompletion { _ in
            completion?()
        }
        animation.startAnimation()
    }
}

extension EditorOverlayVC:UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
        updateMainConstraints(viewController: viewController)
        let hidden = navigationController.viewControllers.count >= 2
        navigationController.setNavigationBarHidden(!hidden, animated: true)
    }
}

extension EditorOverlayVC {
    struct OverlayCollectionData {
        let title:String
        var image:String? = nil
        var imageData:Data? = nil
        var didSelect:(()->())?
        var toOverlay:ToOverlayData? = nil
        var backgroundColor:UIColor? = nil
    }
    
    struct ToOverlayData {
        let screenTitle:String
        var collectionData:[EditorOverlayVC.OverlayCollectionData] = []
        var attachmentType:AttachmentOverlayType? = nil
        var needTextField:Bool? = nil
        var isPopup:Bool = true
        var screenHeight:EditorOverlayContainerVC.OverlaySize? = nil
        var closePressed:(()->())? = nil
        var donePressed:(()->())? = nil
        
        enum AttachmentOverlayType {
            case color (ColorType)
            case floatRange (FloatType)
            case any ((Any)->())
            
            struct ColorType {
                var selectedColor:UIColor? = nil
                var didSelect:(_ newColor:UIColor)->()
            }
            
            struct FloatType {
                var selected:CGFloat? = nil
                var didSelect:(_ newValue:CGFloat)->()
            }
        }
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
        parent.addChild(child: vc, constaits: vc.primaryConstraints(.small))
        vc.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor, constant: -10).isActive = true
        vc.loadSeectionIndocator(bottomView: bottomView, parent: parent)
        vc.animateShow(show: true)
    }
}
