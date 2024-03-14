//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

protocol EditorModelPresenter {
     @MainActor func videoAdded()
     @MainActor func errorAddingVideo()
    var movieURL:URL?{set get}
    @MainActor func reloadUI()
}

class EditorModel {
    var addingUrls:[String] = []
    var presenter:EditorModelPresenter?
    var prepare:PrepareEditorModel!
    var _movie:AVMutableComposition?
    private var dbParametersHolder:DB.DataBase.MovieParametersDB.MovieDB?
    var movieHolder:AVMutableComposition?

    init(presenter:EditorModelPresenter) {
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
                await presenter?.errorAddingVideo()
            }
        }
    }
    
    func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        Task {
            if let text = data as? MovieAttachmentProtocol {
                DB.db.movieParameters.editingMovie?.isOriginalUrl = true
                DB.db.movieParameters.needReloadText = true
                
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
            DB.db.movieParameters.editingMovie?.isOriginalUrl = true
            DB.db.movieParameters.needReloadFilter = true
            await presenter?.reloadUI()
        }
    }
    
    func deleteAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        Task {
            DB.db.movieParameters.editingMovie?.isOriginalUrl = true
            await presenter?.reloadUI()
        }
    }
}

fileprivate extension EditorModel {
    private func addText() {
        print(movie?.duration ?? -3, " addText movie duration")
        Task {
            movieHolder = movie
            if await self.prepare.addText() {
                await videoAdded(canReload: true)
            } else {
                await presenter?.errorAddingVideo()
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
        if DB.db.movieParameters.needReloadText {
            DB.db.movieParameters.needReloadText = false
            DB.db.movieParameters.editingMovie?.isOriginalUrl = false
            addText()
        } else if videoAddedAction {
            await videoAdded(canReload: canReload)
        }
        if DB.db.movieParameters.needReloadFilter && (DB.db.movieParameters.editingMovie?.filter ?? .none) != FilterType.none {
            DB.db.movieParameters.needReloadFilter = false
            DB.db.movieParameters.editingMovie?.isOriginalUrl = false
            await prepare.addFilter()
        }
    }
}


extension EditorModel:PrepareEditorModelDelegate {
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
