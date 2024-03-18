//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

protocol VideoEditorModelPresenter {
    @MainActor func videoAdded()
    @MainActor func errorAddingVideo(_ text:MessageContent?)
    var movieURL:URL?{set get}
    @MainActor func reloadUI()
}

class VideoEditorModel {
    var addingUrls:[String] = []
    var presenter:VideoEditorModelPresenter?
    var prepare:PrepareEditorModel!
    var _movie:AVMutableComposition?
    private var dbParametersHolder:DB.DataBase.MovieParametersDB.MovieDB?
    var movieHolder:AVMutableComposition?
    
    init(presenter:VideoEditorModelPresenter) {
        self.presenter = presenter
        self.prepare = .init(delegate: self)
    }
    
    deinit {
        dbParametersHolder = nil
        movieHolder = nil
        _movie = nil
        presenter = nil
        prepare = nil
    }
    
    static let timeScale = CMTimeScale(NSEC_PER_SEC)
    static let fmp30 = CMTime(value: 1, timescale: 30)
    
    func loadVideo(_ url:URL?, canShowError:Bool = true, videoAddedAction:Bool = true, needExport:Bool = false, canReload:Bool = false) {
        Task {
            let _ = await prepare.createVideo(url, needExport: needExport)
            let db = DB.db.movieParameters
            self.dbParametersHolder = db.editingMovie
            if let url, videoAddedAction {
                await prepare.movieUpdated(movie: movieHolder, movieURL: url)
            }
            await checkVideoInstructions(videoAddedAction: videoAddedAction, canReload: canReload)
        }
    }
    
    func addVideo(force:Bool = false) {
        Task {
            if await prepare.createTestBundleVideo("1", addingVideo: true) {
                await videoAdded()
            } else {
                await presenter?.errorAddingVideo(.init(title: "Error adding video"))
            }
        }
    }
    
    func addSoundPressed(url:URL?) {
        Task {
            let ok = await prepare.addSound(url:url)
            if let _ = ok.videoExportResponse {
                await videoAdded()
            } else {
                await presenter?.errorAddingVideo(ok.error?.messageContent ?? .init(title: "Error adding selected audio"))
            }
        }
    }
    
    func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        Task {
            if (DB.db.movieParameters.editingMovie?.filtered ?? false) {
                await presenter?.errorAddingVideo(.init(title: "Attachments cannot be added when after using filter", description: "set filter to text to modify attachments"))
                return
            }
            if let text = data as? MovieAttachmentProtocol {
                DB.db.movieParameters.editingMovie?.isOriginalUrl = true
                DB.db.movieParameters.needReloadLayerAttachments = true
                DB.db.movieParameters.needReloadFilter = true
                if let textDB = text as? TextAttachmentDB {
                    DB.db.movieParameters.editingMovie!.texts.append(textDB)
                }
                await presenter?.reloadUI()
            } else {
                print("error adding data: nothing to add ", data.debugDescription)
                await videoAdded(canReload:false)
            }
        }
    }
    
    func addFilterPressed() {
        Task {
            /// FA-956
            DB.db.movieParameters.editingMovie?.isOriginalUrl = true
            DB.db.movieParameters.needReloadFilter = true
            DB.db.movieParameters.needReloadLayerAttachments = true
            await presenter?.reloadUI()
            /// FA-956
//            await prepare.addFilter(completion: {
//                Task {
//                    await self.presenter?.reloadUI()
//                }
//            })
        }
    }
    
    func deleteAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        Task {
            DB.db.movieParameters.editingMovie?.isOriginalUrl = true
            await presenter?.reloadUI()
        }
    }
}

fileprivate extension VideoEditorModel {
    private func addText() {
        print(movie?.duration ?? -3, " addText movie duration")
        Task {
            if (DB.db.movieParameters.editingMovie?.texts.isEmpty ?? true) {
                await videoAdded(canReload: false)
                return
            }
            let ok = await self.prepare.addText()
            if let _ = ok.response {
                await videoAdded(canReload: true)
            } else {
                await presenter?.errorAddingVideo(ok.error?.messageContent ?? .init(title: "Error adding text"))
            }
        }
    }
    
    private func videoAdded(canReload:Bool = true) async {
        if DB.db.movieParameters.editingMovie?.texts.count ?? 0 != 0 && canReload {
            await self.presenter?.reloadUI()
        } else {
            await presenter?.videoAdded()
        }
    }
    
    private func checkVideoInstructions(videoAddedAction:Bool = true, canReload:Bool = false) async {
        /// FA-956
        let needFilter = DB.db.movieParameters.needReloadFilter && (DB.db.movieParameters.editingMovie?.filter ?? .none) != FilterType.none
        if DB.db.movieParameters.needReloadLayerAttachments {
            DB.db.movieParameters.needReloadLayerAttachments = false
            DB.db.movieParameters.editingMovie?.isOriginalUrl = false
            if !(DB.db.movieParameters.editingMovie?.filtered ?? false) {
                addText()
            }
        } else if videoAddedAction {
            await videoAdded(canReload: canReload)
        }
        /// FA-956
        if needFilter {
            Task {
                DB.db.movieParameters.needReloadFilter = false
                DB.db.movieParameters.editingMovie?.isOriginalUrl = false
                await self.prepare.addFilter(completion: {
                    Task {
                        await self.presenter?.reloadUI()
                    }
                })
            }
        }
    }
}


extension VideoEditorModel:PrepareEditorModelDelegate {
    var movie: AVMutableComposition? {
        get {
            return _movie
        }
        set {
            _movie = newValue
        }
    }
    
    var movieURL: URL? {
        get {
            presenter?.movieURL
        }
        set {
            presenter?.movieURL = newValue
        }
    }
}
