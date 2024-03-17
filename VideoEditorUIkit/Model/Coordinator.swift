//
//  Coordinator.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation
import UIKit
import MediaPlayer

struct Coordinator {
    private var viewController:UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    func start() {
        UIApplication.shared.keyWindow?.rootViewController = EditorViewController.configure()
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
}

extension Coordinator {
    fileprivate func present(_ viewControllerToPresent:UIViewController, inViewController:UIViewController? = nil, completion:(()->())? = nil) {
        let topVC = inViewController ?? viewController
        if let presented = topVC?.presentedViewController {
            self.present(viewControllerToPresent, inViewController: presented, completion: completion)
        } else {
            topVC?.present(viewControllerToPresent, animated: true, completion: completion)
        }
    }
    
    fileprivate func push(_ viewController:UIViewController) {
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: Reusable
extension Coordinator {
    func toDocumentPicker(delegate:UIDocumentPickerDelegate?) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.aiff, .aliasFile, .appleProtectedMPEG4Audio, .appleProtectedMPEG4Video, .audio, .avi, .audiovisualContent, .video, .mpeg2Video, .appleProtectedMPEG4Video, .mp3, .mpeg, .mpeg4Audio, .movie, .m3uPlaylist, .quickTimeMovie], asCopy: true)
        documentPicker.delegate = delegate
        documentPicker.allowsMultipleSelection = false
        present(documentPicker)
    }
    
    func toAppleMusicList(delegate:MPMediaPickerControllerDelegate?) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        mediaPicker.prompt = "Select sound to video"
        mediaPicker.delegate = delegate
        mediaPicker.allowsPickingMultipleItems = false
        present(mediaPicker)
    }
    
    func toVideoPlayer(movieURL:URL?) {
        let vc = PlayerSuperVC.init()
        vc.movieURL = movieURL
        vc.initialAnimationSet = false
        present(vc)
    }
    
    func toList(tableData:[SelectionTableViewController.TableData]) {
        let vc = SelectionTableViewController.configure()
        present(vc) {
            vc.tableData = tableData
        }
    }
    
    func presentOverlay(parentVC:UIViewController,
                        stickToView:UIView,
                        attachmentData:AssetAttachmentProtocol?,
                        delegate:EditorOverlayVCDelegate?) {
        EditorOverlayVC.addOverlayToParent(parentVC, bottomView: stickToView, attachmentData: attachmentData, delegate: delegate)
    }
}
