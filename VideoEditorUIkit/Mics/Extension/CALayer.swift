//
//  CALayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 14.03.2024.
//

import QuartzCore
import UIKit

extension CALayer {
    func cornerRadius(at position: RadiusPosition, value:CGFloat? = nil) {
        switch position {
        case .left:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .right:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        case .top:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    enum RadiusPosition {
        case left, right, top, bottom
    }
    
    private func createPath(_ lines:[CGPoint]) -> UIBezierPath {
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
    
    func drawLine(_ lines:[CGPoint], color:UIColor? = .gray, width:CGFloat = 0.8, opacity:Float = 0.1, background:UIColor? = nil, insertAt:UInt32? = nil, name:String? = nil) {
        
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
        } else {
            line.path = createPath(lines).cgPath
        }
        
    }
    
    func zoom(value:CGFloat) {
        self.transform = CATransform3DMakeScale(value, value, 1)
    }
    
    enum MoveDirection {
        case top
        case left
    }
    
    func move(_ direction:MoveDirection, value:CGFloat) {
        switch direction {
        case .top:
            self.transform = CATransform3DTranslate(CATransform3DIdentity, 0, value, 0)
        case .left:
            self.transform = CATransform3DTranslate(CATransform3DIdentity, value, 0, 0)
        }
    }
    
    func animationTransition(_ duration:CFTimeInterval = 0.3, type:CATransitionType = .fade) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                .linear)
        animation.type = type
        animation.duration = duration
        add(animation, forKey: type.rawValue)
    }
}
