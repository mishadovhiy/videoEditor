//
//  ViewModelEditorViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 08.03.2024.
//

import Foundation
import UIKit

struct ViewModelEditorViewController {
    var editorModel:EditorModel!
    var viewType:EditorViewType = .addingVideos
    var firstVideoAdded = false
    
    init(editorPresenter:EditorModelPresenter) {
        editorModel = .init(presenter:editorPresenter)
    }
    mutating func `deinit`() {
        editorModel = nil
    }
    
    
    typealias void = ()->()
    func mainEditorCollectionData(vc:UIViewController, filterSelected:@escaping()->(),
                                  reloadPressed:@escaping void,
                                  removeAttachments:@escaping void,
                                  deleteMovie:@escaping void
    ) -> [EditorOverlayVC.OverlayCollectionData] {
        [
            .init(title: "Filter", toOverlay: .init(screenTitle: "Choose filter", collectionData: filterOptionsCollectionData(filterSelected))),
            .init(title: "Reload data", didSelect: reloadPressed),
            .init(title: "Remove all attachments", didSelect: removeAttachments),
            .init(title: "Delete Movie", didSelect: deleteMovie),
            .init(title: (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "is original url" : "is edited url", didSelect: {
                Task {
                    let value = DB.db.movieParameters.editingMovie?.isOriginalUrl ?? false
                    DB.db.movieParameters.editingMovie?.isOriginalUrl = !value
                    await MainActor.run {
                        reloadPressed()
                    }
                }
            }),
            .init(title: "links list", didSelect: {
                toLinkList(parentVC: vc)
            })
        ]
    }
    
    private func loadUrls() -> [URL] {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
            return contents
        } catch {
            return []
        }
    }
    
    func toLinkList(parentVC:UIViewController) {
        let vc = SelectionTableViewController.configure()
        parentVC.present(vc, animated: true)
        vc.tableData = loadUrls().compactMap({ url in
            .init(value: url.absoluteString) {
                self.toPlayerVC(parentVC: parentVC, url: url)
            }
        })
    }
    
    func toPlayerVC(parentVC:UIViewController, url:URL) {
        let vc = PlayerSuperVC.init()
        vc.movieURL = url
        vc.initialAnimationSet = false
        parentVC.present(vc, animated: true)
    }
    
    private func filterOptionsCollectionData(_ filterSelected:@escaping()->()) -> [EditorOverlayVC.OverlayCollectionData] {
        FilterType.allCases.compactMap { filterType in
            .init(title: filterType.rawValue) {
                Task {
                    DB.db.movieParameters.editingMovie?.filter = filterType
                    await MainActor.run {
                        filterSelected()
                    }
                }
            }
        }
    }
}

enum EditorViewType {
    case addingVideos
    case editing
}
