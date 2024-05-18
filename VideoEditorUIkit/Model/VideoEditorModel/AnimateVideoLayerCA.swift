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
        appeareAnimation(data, type: .opacity, newLayer: newLayer, totalTime: totalTime)
        if data.animations.needScale {
            layer.add(repeated(key: "transform.scale", data: data), forKey: "scale")
        }
        layer.addSublayer(newLayer)
    }
    
    func appearenceAnimation(_ data:MovieAttachmentProtocol, type:DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType? = nil, newLayer:CALayer, show:Bool) {
        let animation = self.basicAppeare(type ?? data.animations.appeareAnimation.key, show: show, start: 0, animationDuration: data.animations.appeareAnimation.duration)
        newLayer.add(animation, forKey: show ? "show" : "hode")
    }
    
    private func appeareAnimation(_ data:MovieAttachmentProtocol, type:DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType, newLayer:CALayer, totalTime:CGFloat) {
        let duratioResult = data.time.duration * totalTime
        let startResult = data.time.start * totalTime
        let show = basicAppeare(type, show: true, start: startResult, animationDuration: data.animations.appeareAnimation.duration, alpha: data.opacity)
        newLayer.add(show, forKey: "show")
        let hide = basicAppeare(type, show: false, start: duratioResult + startResult, animationDuration: data.animations.appeareAnimation.duration, alpha: data.opacity)
        newLayer.add(reapeatedState(show, hide, toAlpha: data.opacity), forKey: "visible")
        newLayer.add(hide, forKey: "hide")
    }
}



fileprivate extension AnimateVideoLayer {
    private func repeated(key:String, data:MovieAttachmentProtocol) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: key)
        let difference:CGFloat = 0.05
        let max:CGFloat = 1
        scaleAnimation.fromValue = max - difference
        scaleAnimation.toValue = max
        scaleAnimation.duration = 0.34
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        scaleAnimation.isRemovedOnCompletion = false
        return scaleAnimation
    }
    
    private func reapeatedState(_ show:CABasicAnimation, _ hide:CABasicAnimation,
                                type:DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType = .opacity,
                                toAlpha:CGFloat = 1
    ) -> CABasicAnimation {
        let vidible = CABasicAnimation(keyPath: type.rawValue)
        vidible.fromValue = toAlpha
        vidible.toValue = toAlpha - 0.01
        vidible.duration = 0.1
        vidible.isRemovedOnCompletion = false
        vidible.repeatCount = .greatestFiniteMagnitude
        vidible.beginTime = show.beginTime + show.duration
        vidible.repeatDuration = hide.beginTime - show.beginTime
        return vidible
    }
    
    func basicAppeare(_ key:DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType, show:Bool, start:CFTimeInterval, animationDuration:CGFloat = 0.8, alpha:CGFloat = 1) -> CABasicAnimation {
        
        let message = CABasicAnimation(keyPath: key.rawValue)
        if message.duration == 0 {
            message.duration = animationDuration
        }
        message.fromValue = show ? 0 : alpha
        message.toValue = show ? alpha : 0
        message.autoreverses = false
        message.isRemovedOnCompletion = false
        message.beginTime = start
        return message
    }
}
