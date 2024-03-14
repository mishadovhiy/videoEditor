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
    
    func loadVideo(_ url:URL?, canShowError:Bool = true, videoAddedAction:Bool = true, needExport:Bool = false) {
        Task {
            let _ = await prepare.createVideo(url, needExport: needExport)
            self.dbParametersHolder = DB.db.movieParameters.editingMovie
            if let url, videoAddedAction {
                await prepare.movieUpdated(movie: movieHolder, movieURL: url)
            }
            if videoAddedAction {
                await videoAdded(canReload: false)
            }
        }
    }
    
    func addVideo(force:Bool = false) {
        Task {
            print("addVideoaddVideopressedpressed")
            if await addTestVideos() {
                await videoAdded()
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
    
    func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        if let text = data as? MovieAttachmentProtocol {
            addText(text)
        } else {
            print("error adding data: nothing to add ", data.debugDescription)
            Task {
                await videoAdded(canReload:false)
            }
        }
    }
    
    func addFilterPressed() {
        Task {
            self.movie = nil
            loadVideo(.init(string: DB.db.movieParameters.editingMovie?.originalURL ?? ""), videoAddedAction: false)
            if (DB.db.movieParameters.editingMovie?.filter ?? .none) == FilterType.none {
                await videoAdded()
            } else {
                await prepare.addFilter()
                await videoAdded()
            }
        }
    }
    
    func deleteAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        Task {
            dbParametersHolder = DB.db.movieParameters.editingMovie
            await reloadMovie()
        }
    }
    
    private func reloadMovie() async {
        addingUrls = DB.db.movieParameters.editingMovie?.compositionURLs ?? []
        if let urlString = DB.db.movieParameters.editingMovie?.originalURL,
           let url:URL = .init(string: urlString) {
            self.movie = nil
            self.loadVideo(url, videoAddedAction: false, needExport: true)
            await presenter?.reloadUI()
        } else {
            await videoAdded()
        }
    }

}

//MARK: db
fileprivate extension EditorModel {
    private func videoAdded(canReload:Bool = true) async {
        if DB.db.movieParameters.editingMovie?.texts.count ?? 0 != 0 && canReload {
            await self.presenter?.reloadUI()
        } else {
            await presenter?.videoAdded()
        }
    }
    
    private func addDBTexts() async {
        if let first = dbParametersHolder?.texts.first {
            dbParametersHolder?.texts.removeFirst()
            let _ = await self.prepare.addText(data: first)
            return await addDBTexts()
        } else {
            return
        }
    }
}

extension EditorModel {
    private func addText(_ data:MovieAttachmentProtocol, canAddToDB:Bool = true) {
        print(movie?.duration ?? -3)
        Task {
            if let dbData = data as? TextAttachmentDB,
               canAddToDB {
                DB.db.movieParameters.editingMovie?.texts.append(dbData)
            }
            if await self.prepare.addText(data: data) {
                await videoAdded(canReload: true)
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
}


//MARK: test
fileprivate extension EditorModel {
    private func addTestVideos() async -> Bool {
        let ok = await prepare.createVideo("1", addingVideo: true)
        return ok
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
