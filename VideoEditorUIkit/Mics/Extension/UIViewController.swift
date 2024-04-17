//
//  UIViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.04.2024.
//

import UIKit

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
