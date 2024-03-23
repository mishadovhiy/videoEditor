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
    
    private func loadUrls() -> [URL] {
        return AppDelegate.shared?.fileManager?.contents ?? []
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

extension EditorVCViewMode {
    
    typealias void = ()->()
    enum OverlayPressedModel {
        case reload
        case delete
        case filterSelected
        case toStoredVideos
        case export
        case startAnimating (completed:()->())
    }
    
    func addingVideosEditorData(pressed:@escaping(OverlayPressedModel)->()) -> [EditorOverlayVC.OverlayCollectionData] {
        var data:[EditorOverlayVC.OverlayCollectionData] = []
        if editorModel.movie != nil {
            data.append(.init(title: "Edit", didSelect: {
                pressed(.reload)
            }, buttonColor: .type(.purpure)))
            data.append(.init(title: "Remove last changes", image: "backOval", didSelect: {
                self.coordinator?.showConfirmationAlert("Remove last changes", okPressed: {
                    Task {
                        DB.db.movieParameters.editingMovie?.setPreviusVideoURL()
                        await MainActor.run {
                            pressed(.reload)
                        }
                    }
                })
            }))
            data.append(deleteCell(pressed: pressed))
        }
        return data
    }
    
    func mainEditorCollectionData(pressed:@escaping(OverlayPressedModel)->(), filterPreviewImage:Data?) -> [EditorOverlayVC.OverlayCollectionData] {
        [
            .init(title: "Filter", image: "filterColored", toOverlay: .init(screenTitle: "Choose filter", collectionData: filterOptionsCollectionData(image: filterPreviewImage, {
                pressed(.filterSelected)
            }), screenHeight: .big)),
            .init(title: "Export", image: "export", didSelect: {
                pressed(.startAnimating(completed: {
                    pressed(.export)
                }))
            }, buttonColor: .type(.darkBlue)),
            deleteCell(pressed: pressed),
//            .init(title: (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "Set edited url" : "Set original url", didSelect: {
//                let title = (DB.holder?.movieParameters.editingMovie?.isOriginalUrl ?? false) ? "Set edited url" : "Set original url"
//                self.coordinator?.showConfirmationAlert("Change url to: " + title, okPressed: {
//                    self.toggleOriginalURL(reloadPressed: {
//                        pressed(.reload)
//                    })
//                })
//            }),
//            .init(title: "stored videos", didSelect: {
//                pressed(.toStoredVideos)
//            })
        ]
    }
    
    private func deleteCell(pressed:@escaping(OverlayPressedModel)->()) -> EditorOverlayVC.OverlayCollectionData {
        .init(title: "Delete Movie", image: "trash", didSelect: {
            self.coordinator?.showConfirmationAlert("Delete Movie", okPressed: {
                pressed(.delete)
            })
        }, textColor: .type(.red2))
    }
    
    func storedVideosTableData(parentVC:BaseVC) -> [SelectionTableViewController.TableData] {
        return loadUrls().compactMap({ url in
                .init(value: url.absoluteString) {
                    parentVC.coordinator?.toVideoPlayer(movieURL: url)
                }
        })
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
}

enum EditorViewType {
    case addingVideos
    case editing
}
