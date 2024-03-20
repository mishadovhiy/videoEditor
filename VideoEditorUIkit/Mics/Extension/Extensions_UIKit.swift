//
//  Extensions_UIKit.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit

extension UIApplication {
    var sceneKeyWindow:UIWindow? {
        let scene = self.connectedScenes.first(where: {($0 as? UIWindowScene)?.activationState == .foregroundActive}) as? UIWindowScene
        if #available(iOS 15.0, *) {
            return scene?.keyWindow
        } else {
            return scene?.windows.first(where: {$0.isKeyWindow})
        }
    }
}


extension UIViewController {
    func addChild(child:UIViewController, toView:UIView? = nil, constaits:[NSLayoutConstraint.Attribute:(CGFloat, String)]? = nil, name:String? = nil, toSafeArea:Bool = true) {
        self.addChild(child)
        
        (toView ?? self.view).addSubview(child.view)
        child.view.addConstaits(constaits ?? [.left:(0, ""), .right:(0, ""), .top:(0, ""), .bottom:(0, "")], safeArea: toSafeArea)
        child.didMove(toParent: self)
        if let name {
            child.view.layer.name = name
        }
    }
    
    func setApplicationState(active:Bool) {
        if let baseVC = self as? BaseVC {
            if active {
                baseVC.applicationDidHide()
            } else {
                baseVC.applicationDidAppeare()
            }
        }
    }
}


extension UIImageView {
    func setImage(_ named:String?, superView:UIView? = nil) {
        if let imageString = named,
           let imageRes = UIImage.init(named: imageString)
        {
            image = imageRes
            isHidden = false
            superView?.isHidden = false
        } else {
            isHidden = true
            superView?.isHidden = true
        }
    }
}

extension UIView {
    func removeFromSuper() {
        if let stack = self as? UIStackView {
            stack.arrangedSubviews.forEach {
                $0.removeFromSuper()
            }
        }
        subviews.forEach {
            $0.removeFromSuper()
        }
        layer.sublayers?.forEach({
            $0.removeFromSuperlayer()
        })
        self.layer.removeAllAnimations()
        self.removeFromSuperview()
    }
    
    func addConstaits(_ constants:[NSLayoutConstraint.Attribute:(CGFloat, String)], safeArea:Bool = true, toSuperView:UIView? = nil) {
        guard let superview = self.superview ?? toSuperView else {
            return
        }
        constants.forEach { (key, value) in
            let keyNil = key == .height || key == .width
            let item:Any? = keyNil ? nil : (safeArea ? superview.safeAreaLayoutGuide : superview)
            let constraint:NSLayoutConstraint = .init(item: self, attribute: key, relatedBy: .equal, toItem: item, attribute: key, multiplier: 1, constant: value.0)
            constraint.identifier = value.1
            if keyNil {
                self.addConstraint(constraint)
            } else {
                superview.addConstraint(constraint)
            }
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addConstaits(_ constants:[NSLayoutConstraint.Attribute:CGFloat], safeArea:Bool = true, superView:UIView? = nil) {
        let data = constants
        var dataRes:[NSLayoutConstraint.Attribute: (CGFloat, String)] = [:]
        data.forEach {
            dataRes.updateValue(($0.value, ""), forKey: $0.key)
        }
        addConstaits(dataRes, safeArea: safeArea, toSuperView: superView)
    }
    
    func textFieldBottomConstraint(stickyView:UIView, constant:CGFloat = 0) {
        stickyView.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: constant).isActive = true
        if #available(iOS 17.0, *) {
            self.keyboardLayoutGuide.usesBottomSafeArea = false
        }
        stickyView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    func removeWithAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.layer.zoom(value: 1.3)
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    func appeareAnimation() {
        alpha = 0
        layer.zoom(value: 0.7)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.layer.zoom(value: 1)
        }
    }
    
    func addBluer(frame:CGRect? = nil, style:UIBlurEffect.Style = (.init(rawValue: -10) ?? .regular), insertAt:Int? = nil, isSecond:Bool = false) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let bluer = UIVisualEffectView(effect: blurEffect)
      //  bluer.backgroundColor = .black.withAlphaComponent(0.3)
        let constaints:[NSLayoutConstraint.Attribute : CGFloat] = [.leading:0, .top:0, .trailing:0, .bottom:0]

        for _ in 0..<5 {
            let vibracity = UIVisualEffectView(effect: UIBlurEffect(style: style))
            bluer.contentView.addSubview(vibracity)
            vibracity.addConstaits(constaints, superView: bluer)
        }
        
        bluer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let at = insertAt {
            self.insertSubview(bluer, at: at)
        } else {
            self.addSubview(bluer)
        }
        
        bluer.addConstaits(constaints)

        return bluer
    }
}


extension UIColor {
    static var random:UIColor {
        let all:[UIColor] = [.green.withAlphaComponent(0.3), .blue.withAlphaComponent(0.3), .orange, .green, .blue, .black, .purple]
        return all.randomElement() ?? .red
    }
}

extension UIGestureRecognizer.State {
    var isEnded:Bool {
        switch self {
        case .ended, .cancelled, .failed:
            return true
        default: return false
        }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }
    }
}
