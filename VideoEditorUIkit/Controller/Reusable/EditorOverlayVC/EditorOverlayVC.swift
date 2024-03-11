//
//  EditingOvarlayVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

protocol EditorOverlayVCDelegate {
    func addAttachmentPressed(_ attachmentData:AssetAttachmentProtocol?)
    func overlayRemoved()
}

class EditorOverlayVC: SuperVC {

    private var selectionIndicatorView:UIView? {
        return view.subviews.first(where: {$0.layer.name == "SelectionIndicatorView"})
    }
    
    @IBOutlet var actionButtons: [BaseButton]!
    var attachmentData:AssetAttachmentProtocol?
    private var delegate:EditorOverlayVCDelegate?
    override var initialAnimation: Bool { return false}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 12
        view.subviews.first(where: {$0 is UIStackView})?.layer.cornerRadius = 11
        view.subviews.first(where: {$0 is UIStackView})?.layer.masksToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .init(width: -1, height: 3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigation = children.first(where: {$0 is UINavigationController}) as? UINavigationController {
            navigation.delegate = self
            navigation.navigationBar.sizeThatFits(.init(width: self.view.frame.width, height: 20))
        }
    }
    
    override func removeFromParent() {
        if attachmentData == nil {
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
        let newAlpha:CGFloat = (editingRawView.frame.minX / 2) >= position.minX ? 0 : 1
        if selectionIndicatorView?.alpha ?? 0 != newAlpha {
            UIView.animate(withDuration: 0.2) {
                self.selectionIndicatorView?.alpha = newAlpha
            }
        }
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        delegate?.addAttachmentPressed(attachmentData)
        removeFromParent()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        removeFromParent()
    }
}

fileprivate extension EditorOverlayVC {
    func animateShow(show:Bool, completion:(()->())? = nil) {
        if show {
            view.alpha = 0
            view.layer.zoom(value: 0.7)
        }
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.view.alpha = show ? 1 : 0
            self.view.layer.zoom(value: !show ? 1.2 : 1)
        }
        animation.addCompletion { _ in
            completion?()
        }
        animation.startAnimation()
    }
}

extension EditorOverlayVC {
    static func configure(data:AssetAttachmentProtocol?,
                          delegate:EditorOverlayVCDelegate) -> EditorOverlayVC {
        let vc = UIStoryboard(name: "EditorOverlay", bundle: nil).instantiateViewController(withIdentifier: "EditorOverlayVC") as? EditorOverlayVC ?? .init()
        vc.view.layer.name = String(describing: EditorOverlayVC.self)
        vc.attachmentData = data ?? TextAttachmentDB.init(dict: [:])
        vc.delegate = delegate
        vc.view.alpha = 0
        return vc
    }
    
    static func addToParent(_ parent:UIViewController,
                            bottomView:UIView,
                            data:AssetAttachmentProtocol?,
                            delegate:EditorOverlayVCDelegate
    ) {
        let vc = EditorOverlayVC.configure(data: data, delegate: delegate)
        parent.addChild(child: vc, constaits: vc.primaryConstraints(.small))
        vc.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor, constant: -10).isActive = true
        vc.loadSeectionIndocator(bottomView: bottomView, parent: parent)
        vc.animateShow(show: true)
    }
    
    func primaryConstraints(_ type:EditorOverlayContainerVC.OverlaySize) -> [NSLayoutConstraint.Attribute: (CGFloat, String)] {
        switch type {
        case .small:
            return [.left: (10, "leftprimaryConstraints"), .right:(-10, "rightprimaryConstraints"), .height:(75, "heightprimaryConstraints")]
        case .middle:
            return [.left: (0, "leftprimaryConstraints"), .right:(0, "rightprimaryConstraints"), .height:(100, "heightprimaryConstraints")]
        case .big:
            return [.left: (0, "leftprimaryConstraints"), .right:(0, "rightprimaryConstraints"), .height:(185, "heightprimaryConstraints")]
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
            if (view.superview?.isHidden ?? true) != hidden {
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        view.superview?.isHidden = hidden
                    }
                } else {
                    view.superview?.isHidden = hidden
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
        var didSelect:(()->())?
        var toOverlay:ToOverlayData? = nil
        var backgroundColor:UIColor? = nil
    }
    
    struct ToOverlayData {
        let screenTitle:String
        var collectionData:[EditorOverlayVC.OverlayCollectionData] = []
        var type:AttachmentOverlayType?
        
        enum AttachmentOverlayType {
            case color (ColorType)
            case floatRange ((CGFloat)->())
            case any ((Any)->())
            
            struct ColorType {
                var selectedColor:UIColor? = nil
                var didSelect:(_ newColor:UIColor)->()
            }
        }
    }
}
