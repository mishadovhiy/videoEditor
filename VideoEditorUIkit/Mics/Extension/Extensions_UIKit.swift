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
    func addChild(child:UIViewController, toView:UIView? = nil, constaits:[NSLayoutConstraint.Attribute:CGFloat]? = nil, name:String? = nil) {
        self.addChild(child)
        
        (toView ?? self.view).addSubview(child.view)
        child.view.addConstaits(constaits ?? [.left:0, .right:0, .top:0, .bottom:0], superView: toView ?? self.view)
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



extension CALayer {
    func createPath(_ lines:[CGPoint]) -> UIBezierPath {
        let linePath = UIBezierPath()
        var liness = lines
        guard let lineFirst = liness.first else { return .init() }
        linePath.move(to: lineFirst)
        liness.removeFirst()
        liness.forEach { line in
            linePath.addLine(to: line)
        }
        return linePath
    }
    
    func drawLine(_ lines:[CGPoint], color:UIColor? = .gray, width:CGFloat = 0.5, opacity:Float = 0.1, background:UIColor? = nil, insertAt:UInt32? = nil, name:String? = nil) {
        
        let line = CAShapeLayer()
        let contains = self.sublayers?.contains(where: { $0.name == (name ?? "")} )
        let canAdd = name == nil ? true : !(contains ?? false)
        if canAdd {
            line.path = createPath(lines).cgPath
            line.opacity = opacity
            line.lineWidth = width
            line.strokeColor = (color ?? .red).cgColor
            line.name = name
            if let background = background {
                line.backgroundColor = background.cgColor
                line.fillColor = background.cgColor
            }
            if let at = insertAt {
                self.insertSublayer(line, at: at)
            } else {
                self.addSublayer(line)
            }
            
        } 
        
    }
    
    func zoom(value:CGFloat) {
        self.transform = CATransform3DMakeScale(value, value, 1)
    }
}



extension UIColor {
    static var random:UIColor {
        let all:[UIColor] = [.green.withAlphaComponent(0.3), .blue.withAlphaComponent(0.3), .orange, .green, .blue, .black, .purple]
        return all.randomElement() ?? .red
        
    }
}
