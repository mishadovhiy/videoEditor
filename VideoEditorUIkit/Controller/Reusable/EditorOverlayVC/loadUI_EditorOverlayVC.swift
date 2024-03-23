//
//  loadUI_EditorOverlayVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import UIKit

// MARK: - loadUI
extension EditorOverlayVC {
    func setupUI() {
        let defaultColor = view.superview?.backgroundColor ?? .clear
        if isPopup {
            view.layer.cornerRadius = 12
            view.subviews.first(where: {$0 is UIStackView})?.layer.cornerRadius = 11
            view.subviews.first(where: {$0 is UIStackView})?.layer.masksToBounds = true
            view.layer.shadowColor = UIColor.type(.black).cgColor
            view.layer.shadowOpacity = 0.8
            view.layer.shadowOffset = .init(width: -1, height: 3)
            view.layer.shadowRadius = 5
            let color = attachmentData?.trackColor ?? defaultColor
            view.backgroundColor = color
        } else {
            view.backgroundColor = defaultColor
            actionButtons.first(where: {$0.style == 0})?.superview?.isHidden = hideDoneButton
            actionButtons.first(where: {$0.style == 1})?.superview?.isHidden = hideCloseButton
        }
    }
    
    var hideCloseButton:Bool {
        data?.closePressed == nil && attachmentDelegate == nil
    }
    
    var hideDoneButton:Bool {
        data?.donePressed == nil && attachmentDelegate == nil
    }

    func primaryConstraints(_ type:EditorOverlayContainerVC.OverlaySize) -> [NSLayoutConstraint.Attribute: (CGFloat, String)] {
        switch type {
        case .small:
            return !isPopup ? [.height:(70, "height")] : [.left: (10, "left"), .right:(-10, "right"), .height:(55, "height")]
        case .middle:
            return !isPopup ? [.height:(90, "height")] : [.left: (0, "left"), .right:(0, "right"), .height:(90, "height")]
        case .big:
            return !isPopup ? [.height:(250, "height")] : [.left: (0, "left"), .right:(0, "right"), .height:(185, "height")]
        }
    }
    
    func loadSeectionIndocator(bottomView:UIView, parent:UIViewController) {
        guard let toView = self.view else { return }
        let view = UIView()
        toView.addSubview(view)
        view.layer.name = "SelectionIndicatorView"
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: .init(named: "bottomSelectionIndicator"))
        imageView.tintColor = view.superview?.backgroundColor ?? .red
        view.addSubview(imageView)
        view.topAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        view.leadingAnchor.constraint(lessThanOrEqualTo: bottomView.trailingAnchor, constant: -20).isActive = true
        view.leadingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -10).isActive = true
        imageView.addConstaits([.left:-20, .top:0, .bottom:0])
        let constraint3 = view.trailingAnchor.constraint(greaterThanOrEqualTo: bottomView.leadingAnchor, constant: -10)
        constraint3.priority = .init(rawValue: 250)
        constraint3.isActive = true

        view.addConstaits([.width:50])
    }
    
    func updateMainConstraints(viewController:UIViewController?, textFieldEditing:Bool = false) {
        let appearedVC = viewController ?? childVC
        if let topVC = viewController as? EditorOverlayContainerVC {
            let hidden = (appearedVC?.navigationController?.viewControllers.count ?? 0) >= 2

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
            let animation = UIViewPropertyAnimator(duration:isPopup ? 0.2 : 0.29, curve: .easeIn) {
                self.view.layoutIfNeeded()
                self.view.superview?.layoutIfNeeded()
                viewController?.view.layoutIfNeeded()
            }
            animation.addAnimations({
                self.toggleButtons(hidden: textFieldEditing ? true : hidden, animated: false)
            }, delayFactor: 0.05)
            animation.startAnimation()
            
            overlaySizeChanged?(type)
        }
    }
    
    func toggleButtons(hidden:Bool, animated:Bool = true) {
        actionButtons.forEach { view in
            var hide = hidden
            if !hide && attachmentData == nil {
                hide = view.style == 0 ? data?.donePressed == nil : data?.closePressed == nil
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
