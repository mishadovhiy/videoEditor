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
    
    func lastEditedVideoURL() -> URL? {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

        do {
            let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])

            return contents.last
        } catch {
            print("Error: \(error)")
            return nil
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
        view.addConstaits([.centerX:0, .centerY:0, .width:35, .height:35], superView: self.view)
        view.layer.cornerRadius = view.bounds.size.width / 2
        view.layer.shadowRadius = view.layer.cornerRadius

    }
}
