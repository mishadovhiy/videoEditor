//
//  AppDelegate.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AlertViewLibrary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var coordinator:Coordinator?
    
    static var shared:AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    lazy var ai: AlertManager = .init(appearence: .with({
        $0.defaultText = .with({
            $0.loading = "Loading"
        })
    }))
        
    var fileManager:FileManagerServgice?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        coordinator = .init()
        fileManager = .init()
        Task {
            DB.holder = DB.db
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let appServicesAuthorization = RequestAuthorization()
        appServicesAuthorization.mediaLibrary()
        appServicesAuthorization.photoLibrary()
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.type(.white)]
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

