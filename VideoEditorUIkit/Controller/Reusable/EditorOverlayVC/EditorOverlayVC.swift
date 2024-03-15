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
}

class EditorOverlayVC: SuperVC {

    private var selectionIndicatorView:UIView? {
        return view.subviews.first(where: {$0.layer.name == "SelectionIndicatorView"})
    }
    @IBOutlet private var actionButtons: [BaseButton]!
    
    var data:ToOverlayData?
    var attachmentData:AssetAttachmentProtocol?
    private var delegate:EditorOverlayVCDelegate?
    override var initialAnimation: Bool { return false}
    
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
    
    func updateData(_ data:[OverlayCollectionData]) {
        childVC?.updateData(data)
    }
    
    override func removeFromParent() {
        if !(data?.isPopup ?? true) {
            return
        }
        delegate?.overlayRemoved()
        attachmentData = nil
        view.endEditing(true)
        animateShow(show: false) {
            self.delegate = nil
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
    
    func childChangedData(_ attachmentData:AssetAttachmentProtocol) {
        self.attachmentData = attachmentData
        delegate?.overlayChangedAttachment(attachmentData)
    }
    
    var isHidden:Bool = false {
        didSet {
            let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
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
        if delegate != nil {
            delegate?.addAttachmentPressed(attachmentData)
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
        if show {
            view.alpha = 0
            view.layer.zoom(value: 0.7)
        }
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

// MARK: - loadUI
extension EditorOverlayVC {
    func setupUI() {
        if data?.isPopup ?? true {
            view.layer.cornerRadius = 12
            view.subviews.first(where: {$0 is UIStackView})?.layer.cornerRadius = 11
            view.subviews.first(where: {$0 is UIStackView})?.layer.masksToBounds = true
            view.layer.shadowColor = UIColor.init(.black).cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = .init(width: -1, height: 3)
        } else {
            view.backgroundColor = view.superview!.backgroundColor ?? .clear
            actionButtons.first(where: {$0.style == 2})?.superview?.isHidden = hideDoneButton
            actionButtons.first(where: {$0.style == 1})?.superview?.isHidden = hideCloseButton
        }
    }
    
    var hideCloseButton:Bool {
        data?.closePressed == nil && delegate == nil
    }
    
    var hideDoneButton:Bool {
        data?.donePressed == nil && delegate == nil
    }

    func primaryConstraints(_ type:EditorOverlayContainerVC.OverlaySize) -> [NSLayoutConstraint.Attribute: (CGFloat, String)] {
        switch type {
        case .small:
            return !(data?.isPopup ?? true) ? [.height:(60, "heightprimaryConstraints")] : [.left: (10, "leftprimaryConstraints"), .right:(-10, "rightprimaryConstraints"), .height:(70, "heightprimaryConstraints")]
        case .middle:
            return !(data?.isPopup ?? true) ? [.height:(85, "heightprimaryConstraints")] : [.left: (0, "leftprimaryConstraints"), .right:(0, "rightprimaryConstraints"), .height:(100, "heightprimaryConstraints")]
        case .big:
            return !(data?.isPopup ?? true) ? [.height:(100, "heightprimaryConstraints")] : [.left: (0, "leftprimaryConstraints"), .right:(0, "rightprimaryConstraints"), .height:(185, "heightprimaryConstraints")]
        }
    }
    
    private func loadSeectionIndocator(bottomView:UIView, parent:UIViewController) {
        guard let toView = self.view else { return }
        let view = UIView()
        toView.addSubview(view)
        view.layer.name = "SelectionIndicatorView"
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        view.leadingAnchor.constraint(lessThanOrEqualTo: bottomView.trailingAnchor, constant: -20).isActive = true
        view.leadingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        let constraint3 = view.trailingAnchor.constraint(greaterThanOrEqualTo: bottomView.leadingAnchor, constant: -10)
        constraint3.priority = .init(rawValue: 250)
        constraint3.isActive = true

        view.addConstaits([.width:50])
    }
    
    func updateMainConstraints(viewController:UIViewController, textFieldEditing:Bool = false) {
        if let topVC = viewController as? EditorOverlayContainerVC {
            let hidden = (viewController.navigationController?.viewControllers.count ?? 0) >= 2

            let type = topVC.screenSize ?? (hidden ? .middle : .small)
            let constraints = primaryConstraints(textFieldEditing ? .middle : type)
            constraints.forEach { typeData in
                if let constraint = self.view.constraints.first(where: {
                    $0.identifier == typeData.value.1
                }) {
                    constraint.constant = typeData.value.0
                } else if let constraint = self.view.superview?.constraints.first(where: {
                    $0.identifier == typeData.value.1
                }) {
                    constraint.constant = typeData.value.0
                }
            }
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) {
                self.view.layoutIfNeeded()
                self.view.superview?.layoutIfNeeded()
            }
            animation.addAnimations({
                self.toggleButtons(hidden: textFieldEditing ? true : hidden, animated: false)
            }, delayFactor: 0.05)
            animation.startAnimation()
        }
    }
    
    func toggleButtons(hidden:Bool, animated:Bool = true) {
        actionButtons.forEach { view in
            var hide = hidden
            if !hide && attachmentData == nil {
                hide = view.style == 2 ? data?.donePressed == nil : data?.closePressed == nil
            }
            if (view.superview?.isHidden ?? true) != hide {
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        view.superview?.isHidden = hide
                    }
                } else {
                    view.superview?.isHidden = hide
                }
            }
        }
    }
}

extension EditorOverlayVC:UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
        updateMainConstraints(viewController: viewController)
        let hidden = navigationController.viewControllers.count >= 2
        navigationController.setNavigationBarHidden(!hidden, animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let hidden = navigationController.viewControllers.count >= 2
        if navigationController.isNavigationBarHidden != !hidden {
            navigationController.setNavigationBarHidden(!hidden, animated: true)
        }
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
        var screenHeight:EditorOverlayContainerVC.OverlaySize = .small
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
    static func configure() -> EditorOverlayVC {
        let vc = UIStoryboard(name: "EditorOverlay", bundle: nil).instantiateViewController(withIdentifier: "EditorOverlayVC") as? EditorOverlayVC ?? .init()
        return vc
    }
    
    static func configure(data:ToOverlayData) -> EditorOverlayVC {
        let vc = EditorOverlayVC.configure()
        vc.data = data
        return vc
    }
    
    static func configure(attechemntData:AssetAttachmentProtocol?,
                          delegate:EditorOverlayVCDelegate) -> EditorOverlayVC {
        let vc = EditorOverlayVC.configure()
        vc.view.layer.name = String(describing: EditorOverlayVC.self)
        vc.attachmentData = attechemntData ?? TextAttachmentDB.init(dict: [:])
        vc.delegate = delegate
        vc.view.alpha = 0
        return vc
    }
    
    static func addOverlayToParent(_ parent:UIViewController,
                            bottomView:UIView,
                            attachmentData:AssetAttachmentProtocol?,
                            delegate:EditorOverlayVCDelegate
    ) {
        let vc = EditorOverlayVC.configure(attechemntData: attachmentData, delegate: delegate)
        parent.addChild(child: vc, constaits: vc.primaryConstraints(.small))
        vc.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor, constant: -10).isActive = true
        vc.loadSeectionIndocator(bottomView: bottomView, parent: parent)
        vc.animateShow(show: true)
    }
}
