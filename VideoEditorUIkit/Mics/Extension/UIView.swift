//
//  UIView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.04.2024.
//

import UIKit

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
        if #available(iOS 15.0, *) {
            stickyView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor).isActive = true
        }
    }
    
    func removeWithAnimation() {
        if superview == nil {
            return
        }
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
