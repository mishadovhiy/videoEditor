//
//  UIApplication.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.04.2024.
//

import UIKit

extension UIApplication {
    var sceneKeyWindow:UIWindow? {
        let scene = self.connectedScenes.first(where: {($0 as? UIWindowScene)?.activationState == .foregroundActive}) as? UIWindowScene
        if #available(iOS 15.0, *) {
            return scene?.keyWindow
        } else {
            return scene?.windows.first(where: {$0.isKeyWindow})
        }
    }
    
    var keyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }
    }
}
