//
//  AnimateVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 06.01.2024.
//

import Foundation
import AVFoundation

struct AnimateVideoLayer {
    struct AnimationProperties {
        var needScale = false
    }
    func add(_ newLayer:CALayer, to layer: CALayer, duration:CGFloat, properties:AnimationProperties) {
        newLayer.opacity = 0
        appeareAnimation(.opacity, duration: duration, newLayer: newLayer)
        if properties.needScale {
            layer.add(repeated(key: "transform.scale"), forKey: "scale")

        }
        layer.addSublayer(newLayer)
    }
    
    
    private func appeareAnimation(_ type:AppeareAnimationType, duration:CGFloat, newLayer:CALayer) {

        let show = basicAppeare(type, show: true, start: duration * 0.2)
        newLayer.add(show, forKey: "show")
        let hide = basicAppeare(type, show: false, start: duration * 0.8)
        newLayer.add(reapeatedState(show, hide), forKey: "visible")
        newLayer.add(hide, forKey: "hide")
    }
    
    enum AppeareAnimationType:String {
        case opacity = "opacity"
    }
}



fileprivate extension AnimateVideoLayer {
    private func repeated(key:String) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: key)
        scaleAnimation.fromValue = 0.9
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        scaleAnimation.isRemovedOnCompletion = false
        return scaleAnimation
    }
    
    private func reapeatedState(_ show:CABasicAnimation, _ hide:CABasicAnimation,
                                type:AppeareAnimationType = .opacity
    ) -> CABasicAnimation {
        let vidible = CABasicAnimation(keyPath: type.rawValue)
        vidible.fromValue = 1
        vidible.toValue = 0.99
        vidible.duration = 0.1
        vidible.isRemovedOnCompletion = false
        vidible.repeatCount = .greatestFiniteMagnitude
        vidible.beginTime = show.beginTime + show.duration
        vidible.repeatDuration = hide.beginTime - show.beginTime
        return vidible
    }
    
    func basicAppeare(_ key:AppeareAnimationType, show:Bool, start:CFTimeInterval) -> CABasicAnimation {
        
        let message = CABasicAnimation(keyPath: key.rawValue)
        if message.duration == 0 {
            message.duration = 0.8
        }
        message.fromValue = show ? 0 : 1
        message.toValue = show ? 1 : 0
        message.autoreverses = false
        message.isRemovedOnCompletion = false
        message.beginTime = start
        return message
    }
}
