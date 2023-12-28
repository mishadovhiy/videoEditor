//
//  SuperVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import SwiftUI

class SuperVC:LoaderVC {
    func addSwiftUIView(_ swiftUIView:some View, height:CGFloat? = nil, toView:UIView? = nil) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        self.addChild(child: hostingController, constants: [
            .left:0, .bottom:0, .right:0, .top:0
        ], name: "addSwiftUIView", toView: toView)
    }
}

class LoaderVC:UIViewController {
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
        view.startAnimating()
        view.addConstaits([.centerX:0, .centerY:0], superView: self.view)
    }
}
