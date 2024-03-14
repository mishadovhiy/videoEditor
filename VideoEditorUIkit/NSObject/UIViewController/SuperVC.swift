//
//  SuperVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AlertViewLibrary

class BaseVC:UIViewController {
    
    override func removeFromParent() {
        children.forEach({
            $0.removeFromParent()
        })
        super.removeFromParent()
    }
    
    func applicationDidAppeare() {
        children.forEach({
            $0.setApplicationState(active: true)
        })
        if let vc = presentedViewController {
            vc.setApplicationState(active: true)
        }
    }
    
    func applicationDidHide() {
        children.forEach({
            $0.setApplicationState(active: false)
        })
        if let vc = presentedViewController {
            vc.setApplicationState(active: false)
        }
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let vc = self.presentedViewController {
            vc.dismiss(animated: true) {
                super.present(viewControllerToPresent, animated: flag, completion: completion)
            }
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    func lastEditedVideoURL() -> URL? {
        .init(string: DB.db.movieParameters.editingMovieURL ?? "")
    }
    
    func showAlert(title:String, appearence:AlertViewLibrary.AlertShowMetadata? = .type(.standard)) {
        AppDelegate.shared.ai.showAlert(title: "Error", appearence: .type(.error))
    }
}

class SuperVC:LoaderVC {
    
}

class LoaderVC:BaseVC {
    var initialAnimationSet:Bool = true
    var initialAnimation:Bool {
        return initialAnimationSet
    }
    
    override func loadView() {
        super.loadView()
        self.addLoaderView()
    }
    
    func endRefreshing(completion:(()->())? = nil) {
        toggleAnimating(false, completion: completion)
    }
    
    func startRefreshing(completion:(()->())? = nil) {
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
