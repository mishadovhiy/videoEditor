//
//  UIView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.04.2024.
//

import UIKit

extension UIView {
    static var nibName:String {
        return String(describing: Self.self)
    }
    
    static func loadFromNib() -> Self? {
        let nib = UINib(nibName: nibName, bundle: nil)
        let view = nib.instantiate(withOwner: nil).first as? Self
        view?.layer.name = nibName
        return view
    }
    
    func convertedToImage(bounds:CGRect? = nil) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds ?? self.bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    var viewController:UIViewController? {
        var nextResponder: UIResponder? = self
        var attempt = 2000
        while let responder = nextResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            if attempt <= 0 {
                return nil
            }
            nextResponder = responder.next
            attempt -= 1
        }
        return nil
    }
    
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
    
}

extension UITextField {
    func setKeyboard(view:UIView, selector:Selector?) {
        self.inputView = view
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: selector)
        toolbar.setItems([doneButton], animated: true)
        self.inputAccessoryView = toolbar
    }
}


extension UIDatePicker {
    static var birthday:UIDatePicker {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }
}
