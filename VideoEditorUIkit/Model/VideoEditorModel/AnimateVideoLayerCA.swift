//
//  AnimateVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 06.01.2024.
//

import Foundation
import AVFoundation

struct AnimateVideoLayer {
    func add(_ newLayer:CALayer, to layer: CALayer, data:MovieAttachmentProtocol, totalTime:CGFloat) {
        newLayer.opacity = 0
        appeareAnimation(.opacity, duration: data.time.duration, newLayer: newLayer, start: data.time.start, totalTime: totalTime)
        if data.animations.needScale {
            layer.add(repeated(key: "transform.scale"), forKey: "scale")
        }
        layer.addSublayer(newLayer)
    }
    
    
    private func appeareAnimation(_ type:AppeareAnimationType, duration:CGFloat, newLayer:CALayer, start:CGFloat, totalTime:CGFloat) {
        let duratioResult = duration * totalTime
        let startResult = start * totalTime
        let show = basicAppeare(type, show: true, start: startResult)
        newLayer.add(show, forKey: "show")
        let hide = basicAppeare(type, show: false, start: duratioResult + startResult)
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
        scaleAnimation.fromValue = 0.93
        scaleAnimation.toValue = 1.05
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
