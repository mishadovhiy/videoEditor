//
//  SuperVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit

class BaseVC:UIViewController {
    
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
    
    func clearTemporaryDirectory(exept:URL? = nil) {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

        do {
            let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])

            try contents.forEach({
                if $0 != exept {
                    try fileManager.removeItem(at: $0)
                    print("Removed: \($0.lastPathComponent)")
                }
            })
        } catch {
            print("Error: \(error)")
        }
    }
}

class SuperVC:LoaderVC {
    
}

class LoaderVC:BaseVC {
    var initialAnimation:Bool {
        return true
    }
    
    override func loadView() {
        print(#function, " loadViewvcc:", self.classForCoder.description())
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
        guard let view = self.view.subviews.first(where: {$0.layer.name == "loaderView"}) as? UIActivityIndicatorView,
              view.isAnimating == animating
        else {
            completion?()
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            view.backgroundColor = animating ? .clear : .red
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
        self.view.addSubview(view)
        if initialAnimation {
            view.startAnimating()
        }
        view.addConstaits([.centerX:0, .centerY:0], superView: self.view)
    }
}
