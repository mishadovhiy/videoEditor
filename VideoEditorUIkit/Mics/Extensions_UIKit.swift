//
//  Extensions_UIKit.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit

extension UIView {
    func addConstaits(_ constants:[NSLayoutConstraint.Attribute:CGFloat], superView:UIView, safeArea:Bool = true) {
        constants.forEach { (key, value) in
            let keyNil = key == .height || key == .width
            let item:Any? = keyNil ? nil : (safeArea ? superView.safeAreaLayoutGuide : superView)
            superView.addConstraint(.init(item: self, attribute: key, relatedBy: .equal, toItem: item, attribute: key, multiplier: 1, constant: value))
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIViewController {
    func addChild(child:UIViewController, constants:[NSLayoutConstraint.Attribute:CGFloat]? = nil, name:String? = nil, toView:UIView? = nil) {
        addChild(child)
        (toView ?? view).addSubview(child.view)
        if let name {
            child.view.layer.name = name
        }
        child.didMove(toParent: self)
        child.view.addConstaits(constants ?? [
            .left:0, .right:0, .top:0, .bottom:0
        ], superView: (toView ?? view))
    }
}
