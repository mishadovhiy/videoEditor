//
//  Coordinator.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation
import UIKit
import MediaPlayer
import AlertViewLibrary

struct Coordinator {
    private var viewController:UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    func start() {
        UIApplication.shared.keyWindow?.rootViewController = EditorViewController.configure()
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }    
}

fileprivate extension Coordinator {
    func present(_ viewControllerToPresent:UIViewController, inViewController:UIViewController? = nil, completion:(()->())? = nil) {
        let topVC = inViewController ?? viewController
        if let presented = topVC?.presentedViewController {
            self.present(viewControllerToPresent, inViewController: presented, completion: completion)
        } else {
            topVC?.present(viewControllerToPresent, animated: true, completion: completion)
        }
    }
    
    func push(_ viewController:UIViewController) {
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setModalPresentation(_ vc:UIViewController) {
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .formSheet
    }
}

// MARK: Reusable
extension Coordinator {
    func toDocumentPicker(delegate:UIDocumentPickerDelegate?) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.aiff, .aliasFile, .appleProtectedMPEG4Audio, .appleProtectedMPEG4Video, .audio, .avi, .audiovisualContent, .video, .mpeg2Video, .appleProtectedMPEG4Video, .mp3, .mpeg, .mpeg4Audio, .movie, .m3uPlaylist, .quickTimeMovie], asCopy: true)
        documentPicker.delegate = delegate
        documentPicker.allowsMultipleSelection = false
        setModalPresentation(documentPicker)
        present(documentPicker)
    }
    
    func toAppleMusicList(delegate:MPMediaPickerControllerDelegate?) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        setModalPresentation(mediaPicker)
        mediaPicker.delegate = delegate
        mediaPicker.allowsPickingMultipleItems = false
        present(mediaPicker)
    }
    
    func toPhotoLibrary(delegate:MPMediaPickerControllerDelegate?) {
        
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

// MARK: - AlertView
extension Coordinator {
    func showAlert(title:String, description:String? = nil, appearence:AlertViewLibrary.AlertShowMetadata? = .type(.standard)) {
        AppDelegate.shared?.ai.showAlert(title: title, description: description, appearence: appearence)
    }
    
    func showErrorAlert(title:String, description:String? = nil) {
        self.showAlert(title: title, description: description, appearence: .type(.error))
    }
    
    func showConfirmationAlert(_ confirmTitle:String, okPressed:@escaping ()->()) {
        showAlertWithCancel(title: "Are you sure you want to\n" + confirmTitle, description: "This action cannot be undone", type: .error, okPressed: okPressed)
    }
    
    func showAlertWithCancel(title:String? = nil, description:String? = nil, type:AlertViewLibrary.ViewType = .standard, okPressed:@escaping ()->()) {
        AppDelegate.shared?.ai.showAlert(title: title, description: description, appearence: .with({
            $0.type = type
            $0.primaryButton = .with({
                $0.action = okPressed
                $0.title = "OK"
            })
            $0.secondaryButton = .with({
                $0.style = .error
                $0.title = "Cancel"
            })
        }))
    }
}
