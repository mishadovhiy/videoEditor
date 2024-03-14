//
//  AppDelegate.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AlertViewLibrary
import Photos

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared:AppDelegate {
        return UIApplication.shared.delegate as? AppDelegate ?? .init()
    }
    
    lazy var ai: AlertManager = .init(appearence: .with({
        $0.defaultText = .with({
            $0.loading = "Loading"
        })
    }))
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        PHPhotoLibrary.requestAuthorization { PHAuthorizationStatus in
            if PHAuthorizationStatus == .authorized {
                
            }
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let vc = UIApplication.shared.sceneKeyWindow?.rootViewController else {
            return
        }
        vc.setApplicationState(active: true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        guard let vc = UIApplication.shared.sceneKeyWindow?.rootViewController else {
            return
        }
        vc.setApplicationState(active: false)
    }
    
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

