//
//  ViewModelEditorViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 08.03.2024.
//

import Foundation
import UIKit

struct EditorVCViewMode {
    var editorModel:VideoEditorModel!
    var viewType:EditorViewType = .addingVideos
    var firstVideoAdded = false
    
    init(editorPresenter:VideoEditorModelPresenter) {
        editorModel = .init(presenter:editorPresenter)
    }
    
    private var coordinator:Coordinator? {
        return AppDelegate.shared?.coordinator
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
                self.coordinator?.showConfirmationAlert("Delete Movie", okPressed: deleteMovie)
            }),
            .init(title: (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "Set edited url" : "Set original url", didSelect: {
                let title = (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "Set edited url" : "Set original url"
                self.coordinator?.showConfirmationAlert("Change url to: " + title, okPressed: {
                    self.toggleOriginalURL(reloadPressed: reloadPressed)
                })
            }),
            .init(title: "stored videos", didSelect: {
                vc.coordinator?.toList(tableData: storedVideosTableData(parentVC: vc))
            })
        ]
    }
    
    private func storedVideosTableData(parentVC:BaseVC) -> [SelectionTableViewController.TableData] {
        return loadUrls().compactMap({ url in
                .init(value: url.absoluteString) {
                    parentVC.coordinator?.toVideoPlayer(movieURL: url)
                }
        })
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
