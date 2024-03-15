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
        view.removeFromSuperview()
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
}

extension BaseVC {
    func showAlert(title:String, appearence:AlertViewLibrary.AlertShowMetadata? = .type(.standard)) {
        AppDelegate.shared.ai.showAlert(title: "Error", appearence: .type(.error))
    }
    
    func showAlertWithCancel(confirmTitle:String, okPressed:@escaping ()->()) {
        showAlertWithCancel(title: "Are you sure you want to\n" + confirmTitle, description: "This action cannot be undone", type: .error, okPressed: okPressed)
    }
    
    func showAlertWithCancel(title:String? = nil, description:String? = nil, type:AlertViewLibrary.ViewType = .standard, okPressed:@escaping ()->()) {
        AppDelegate.shared.ai.showAlert(title: title, description: description, appearence: .with({
            $0.type = type
            $0.primaryButton = .with({
                $0.action = okPressed
                $0.title = "OK"
            })
            $0.secondaryButton = .with({
                $0.style = .error
                $0.title = "Cancel"
            })
        }))
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
