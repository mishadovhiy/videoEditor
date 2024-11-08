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
        if isPopup {
            view.layer.cornerRadius = 12
            view.subviews.first(where: {$0 is UIStackView})?.layer.cornerRadius = 11
            view.subviews.first(where: {$0 is UIStackView})?.layer.masksToBounds = true
            view.layer.shadowColor = UIColor.type(.black).cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = .init(width: -1, height: 3)
            view.layer.shadowRadius = 5
            view.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
            view.layer.borderWidth = 0.5
        } else {
            actionButtons.first(where: {$0.style == 0})?.superview?.isHidden = hideDoneButton
            actionButtons.first(where: {$0.style == 1})?.superview?.isHidden = hideCloseButton
        }
        setBackground()
    }
    
    func setBackground() {
        let defaultColor = view.superview?.backgroundColor ?? .clear
        if isPopup {
            let color = attachmentData?.trackColor ?? defaultColor
            view.backgroundColor = color
            (children.first as? UINavigationController)?.viewControllers.forEach({
                if let vc = $0 as? EditorOverlayContainerVC {
                    vc.setBackground()
                }
            })
        } else {
            view.backgroundColor = defaultColor
        }
        if let bottomIndicator = view.subviews.first(where: {
            $0.layer.name == "SelectionIndicatorView"
        })?.subviews.first(where: {$0 is UIImageView}) as? UIImageView {
            bottomIndicator.tintColor = view.backgroundColor
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
            return !isPopup ? [.height:(60, "height")] : [.left: (10, "left"), .right:(-10, "right"), .height:(55, "height")]
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
           // updateConstraintAnimation.stopAnimation(false)
            print("updateConstraintAnimation tgerfwd")
            UIView.animate(withDuration: 0.34) {
                self.view.layoutIfNeeded()
                self.view.superview?.layoutIfNeeded()
                viewController?.view.layoutIfNeeded()
                self.toggleButtons(hidden: textFieldEditing ? true : hidden, animated: false)
            } completion: { _ in
                
            }

//            updateConstraintAnimation.addAnimations {
//
//            }//here
//            updateConstraintAnimation.startAnimation()
//
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

extension EditorOverlayVC {
    struct OverlayCollectionData {
        let title:String
        var image:String? = nil
        var imageData:Data? = nil
        var didSelect:(()->())?
        var toOverlay:ToOverlayData? = nil
        var backgroundColor:UIColor? = nil
        var buttonColor:UIColor? = nil
        var textColor:UIColor? = nil
    }
    
    struct ToOverlayData {
        let screenTitle:String
        var collectionData:[EditorOverlayVC.OverlayCollectionData] = []
        var attachmentType:AttachmentOverlayType? = nil
        var needTextField:Bool? = nil
        var isPopup:Bool = true
        var screenHeight:EditorOverlayContainerVC.OverlaySize? = nil
        var tableData:[ToOverlayData.AttachmentOverlayType] = []
        var closePressed:(()->())? = nil
        var donePressed:(()->())? = nil
        var screenOverlayButton:ButtonData? = nil
        enum AttachmentOverlayType {
            case color (ColorType)
            case floatRange (FloatType)
            case `switch` (SwitchType)
            case segmented (StringListType)
            case any ((Any)->())
            
            struct ColorType {
                var title:String = ""
                var selectedColor:UIColor? = nil
                var didSelect:(_ newColor:UIColor)->()
            }
            
            struct FloatType {
                var title:String = ""
                var selected:CGFloat? = nil
                var didSelect:(_ newValue:CGFloat)->()
            }
            
            struct StringListType {
                let title:String
                let list:[String]
                let selectedAt:Int
                var didSelect:(_ at:Int)->()
            }
                
            struct SwitchType {
                var title:String = ""
                var selected:Bool = false
                var didSselect:(_ newValue:Bool)->()
            }
        }
    }
}
