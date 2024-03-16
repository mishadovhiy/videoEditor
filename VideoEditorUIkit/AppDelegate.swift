//
//  AppDelegate.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 26.12.2023.
//

import UIKit
import AlertViewLibrary
import Photos
import MediaPlayer

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
        PHPhotoLibrary.requestAuthorization { PHAuthorizationStatus in
            if PHAuthorizationStatus == .authorized {
                
            }
        }
        MPMediaLibrary.requestAuthorization { status in
            print(status.rawValue, " hrtgerfewdaw")
            switch status {
            case .authorized:
                // User granted access to their music library
                // You can now access their music library using MPMediaLibrary APIs
                break
            case .restricted:
                // User's access to their music library is restricted (e.g., parental controls)
                break
            case .denied:
                // User denied access to their music library
                break
            case .notDetermined:
                // User hasn't yet made a choice
                break
            default:
                break
            }
        }
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.type(.white)]
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

