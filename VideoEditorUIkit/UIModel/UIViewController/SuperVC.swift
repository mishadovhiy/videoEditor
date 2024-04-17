//
//  SuperVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AlertViewLibrary

class SuperVC:LoaderVC { }

class BaseVC:UIViewController {
    
    var coordinator:Coordinator? {
        return AppDelegate.shared?.coordinator
    }
    
    override func removeFromParent() {
        children.forEach({
            $0.view.removeFromSuper()
            $0.removeFromParent()
        })
        view.removeFromSuper()
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
    
    var lastEditedVideoURL: URL? {
        .init(string: DB.db.movieParameters.editingMovieURL ?? "")
    }
}

