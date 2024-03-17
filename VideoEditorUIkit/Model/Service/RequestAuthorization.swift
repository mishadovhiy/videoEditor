//
//  RequestAuthorization.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation
import MediaPlayer
import Photos

struct RequestAuthorization {
    func mediaLibrary() {
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
    }
    
    func photoLibrary() {
        PHPhotoLibrary.requestAuthorization { PHAuthorizationStatus in
            if PHAuthorizationStatus == .authorized {
                
            }
        }
    }
}
