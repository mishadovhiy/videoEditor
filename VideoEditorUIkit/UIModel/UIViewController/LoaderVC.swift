//
//  LoaderVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import UIKit

class LoaderVC:BaseVC {
    var isAnimating:Bool = true
    var initialAnimationSet:Bool = true
    var initialAnimation:Bool {
        return initialAnimationSet
    }

    override func loadView() {
        super.loadView()
        self.addLoaderView()
    }
    
    func endRefreshing(completion:(()->())? = nil) {
        isAnimating = false
        toggleAnimating(false, completion: completion)
    }
    
    func startRefreshing(canReturn:Bool = false, completion:(()->())? = nil) {
        if isAnimating && canReturn {
            audioBox?.vibrate(.error)
            return
        }
        isAnimating = true
        toggleAnimating(true, completion: completion)
    }
    
    private func toggleAnimating(_ animating:Bool, completion:(()->())? = nil) {
        guard let view = self.view.subviews.first(where: {$0.layer.name == "loaderView"}) as? UIActivityIndicatorView
        else {
            completion?()
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = animating ? 1 : 0
        }, completion: { _ in
            if animating {
                view.startAnimating()
                
            } else {
                view.stopAnimating()
            }
            
            completion?()
        })
    }
    
}


fileprivate extension LoaderVC {
    func addLoaderView() {
        if let _ = self.view.subviews.first(where: {$0.layer.name == "loaderView"}) as? UIActivityIndicatorView {
            return
        }
        let view = UIActivityIndicatorView(style: .medium)
        view.layer.name = "loaderView"
        view.layer.zPosition = 9999
        view.hidesWhenStopped = true
        view.tintColor = .white
        view.backgroundColor = .white.withAlphaComponent(0.6)
        view.layer.shadowColor = UIColor.white.cgColor
        self.view.addSubview(view)
        if initialAnimation {
            view.startAnimating()
        }
        view.addConstaits([.centerX:0, .centerY:0, .width:35, .height:35])
        view.layer.cornerRadius = view.bounds.size.width / 2
        view.layer.shadowRadius = view.layer.cornerRadius
    }
}

