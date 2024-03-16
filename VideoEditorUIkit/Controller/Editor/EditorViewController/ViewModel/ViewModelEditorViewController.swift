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
    func mainEditorCollectionData(vc:BaseVC, filterPreviewImage:Data?, filterSelected:@escaping()->(),
                                  reloadPressed:@escaping void,
                                  removeAttachments:@escaping void,
                                  deleteMovie:@escaping void
    ) -> [EditorOverlayVC.OverlayCollectionData] {
        [
            .init(title: "Filter", image: "filter", toOverlay: .init(screenTitle: "Choose filter", collectionData: filterOptionsCollectionData(image: filterPreviewImage, filterSelected), screenHeight: .big)),
            .init(title: "Reload data", didSelect: reloadPressed),
            .init(title: "add test sound", didSelect: {
                removeAttachments()
            }),
            .init(title: "Delete Movie", image: "trash", didSelect: {
                vc.showAlertWithCancel(confirmTitle:"Delete Movie", okPressed: deleteMovie)
            }),
            .init(title: (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "Set edited url" : "Set original url", didSelect: {
                let title = (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "Set edited url" : "Set original url"
                vc.showAlertWithCancel(confirmTitle:"Change url to: " + title, okPressed: {
                    self.toggleOriginalURL(reloadPressed: reloadPressed)
                })
            }),
            .init(title: "stored videos", didSelect: {
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
    
    private func filterOptionsCollectionData(image:Data?, _ filterSelected:@escaping()->()) -> [EditorOverlayVC.OverlayCollectionData] {
        let defaultImage:UIImage = .init(systemName: "nosign.app.fill")!
        let image:UIImage = image != nil ? (.init(data: image!) ?? defaultImage) : defaultImage
        return FilterType.allCases.compactMap { filterType in
                .init(title: filterType.title, imageData: image.applyFilter(filterName: filterType.rawValue)?.jpegData(compressionQuality: 0.1) ?? image.jpegData(compressionQuality: 0.1)) {
                Task {
                    DB.db.movieParameters.editingMovie?.filter = filterType
                    await MainActor.run {
                        filterSelected()
                    }
                }
            }
        }
    }
    
    func toggleOriginalURL(reloadPressed:@escaping()->()) {
        Task {
            let value = DB.db.movieParameters.editingMovie?.isOriginalUrl ?? false
            DB.db.movieParameters.editingMovie?.isOriginalUrl = !value
            await MainActor.run {
                reloadPressed()
            }
        }
    }
}

enum EditorViewType {
    case addingVideos
    case editing
}
