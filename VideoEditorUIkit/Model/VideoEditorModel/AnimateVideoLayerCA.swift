//
//  AnimateVideoLayer.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 06.01.2024.
//

import Foundation
import AVFoundation

struct AnimateVideoLayer {
    func add(_ newLayer:CALayer? = nil, to layer: CALayer, data:MovieAttachmentProtocol, totalTime:CGFloat? = nil) {
        if let totalTime, let newLayer {
            newLayer.opacity = 0
            appeareAnimation(data, type: .opacity, newLayer: newLayer, totalTime: totalTime)
        }
        if let animation = data.animations.repeatedAnimations
        {
            (newLayer ?? layer).add(repeated(key: animation.key, data: data), forKey: "scale")
        }
        if let newLayer {
            layer.addSublayer(newLayer)
        }

    }
    
    func appearenceAnimation(_ data:MovieAttachmentProtocol, type:DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType? = nil, newLayer:CALayer, show:Bool) {
        let animation = self.basicAppeare(type ?? data.animations.appeareAnimation.key, show: show, start: 0, animationDuration: data.animations.appeareAnimation.duration)
        newLayer.add(animation, forKey: show ? "show" : "hode")
    }
    
    private func appeareAnimation(_ data:MovieAttachmentProtocol, type:DB.DataBase.MovieParametersDB.AnimationMovieAttachment.AnimationData.AppeareAnimationType, newLayer:CALayer, totalTime:CGFloat) {
        let duratioResult = data.time.duration * totalTime
        let startResult = data.time.start * totalTime
        let show = basicAppeare(type, show: true, start: startResult, animationDuration: data.animations.appeareAnimation.duration, alpha: type == .opacity ? data.opacity : 1)
        newLayer.add(show, forKey: "show")
        let hide = basicAppeare(type, show: false, start: duratioResult + startResult, animationDuration: data.animations.appeareAnimation.duration, alpha: 0)
        newLayer.add(reapeatedState(show, hide, toAlpha: data.opacity), forKey: "visible")
        newLayer.add(hide, forKey: "hide")
    }
}



fileprivate extension AnimateVideoLayer {
    private func repeated(key:AppeareAnimationType, data:MovieAttachmentProtocol) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: key.stringValue)
        let max:CGFloat = data.opacity
        let difference:CGFloat = key == .scale ? 0.05 : (max - 0.3)
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
        let vidible = CABasicAnimation(keyPath: type.stringValue)
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
        /**
         borderColor
         borderWidth
         bounds
         compositingFilter
         contents
         contentsRect
         cornerRadius
         doubleSided
         filters
         frame
         hidden
         mask
         masksToBounds
         + opacity
         + transform.scale
         position
         shadowColor
         shadowOffset
         shadowOpacity
         shadowPath
         shadowRadius
         sublayers
         sublayerTransform
         transform
         zPosition
         */
        let message = CABasicAnimation(keyPath: key.stringValue)
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
