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
    @MainActor func deleteAllData()
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
    
    func loadVideo(_ url:URL?, canShowError:Bool = true, videoAddedAction:Bool = true) {
        Task {
            let _ = await prepare.createVideo(url, needExport: false)
            self.dbParametersHolder = DB.db.movieParameters.editingMovie
            if let url {
                await prepare.movieUpdated(movie: movieHolder, movieURL: url)
            }
            if videoAddedAction {
                await videoAdded(canReload: false)
            }
        }
    }
    
    func addVideo(force:Bool = false) {
        Task {
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
            await prepare.addFilter()
            await videoAdded()
        }
    }
    
    func deleteAttachmentPressed(_ data:AssetAttachmentProtocol?) {
//        Task {
//            var holder = DB.db.movieParameters.editingMovie
//            if let text = data as? (any MovieAttachmentProtocol),
//            let textDBModel = text as? TextAttachmentDB {
//                holder?.texts.removeAll(where: {$0 == textDBModel})
//            }
//            DB.db.movieParameters.editingMovie = holder
//            dbParametersHolder = holder
//            await reloadMovie()
//        }
    }
    
    private func reloadMovie() async {
        movie = .init()
        addingUrls = DB.db.movieParameters.editingMovie?.compositionURLs ?? []
        if let urlString = DB.db.movieParameters.editingMovie?.originalURL,
           let url:URL = .init(string: urlString) {
            self.loadVideo(url, videoAddedAction: true)
        }
        await addDBTexts()
        await videoAdded()
    }
    
    func loadEditingVideos(db:DB.DataBase.MovieParametersDB.MovieDB?) async {
        if let urls = addingUrls.first {
            if await addVideosDB(urls: urls) {
            }
        }
    }

}

//MARK: db
fileprivate extension EditorModel {
    private func videoAdded(canReload:Bool = true) async {
        if DB.db.movieParameters.editingMovie?.texts.count ?? 0 != 0 && canReload {
            await self.presenter?.deleteAllData()
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
        let urls:[String] = ["1"]
        for url in urls {
            let ok = await prepare.createVideo(url, addingVideo: true)
            if ok {
                if url == urls.last {
                    return true
                }
            }
        }
        return false
    }
    private func addVideosDB(urls:String) async -> Bool {
        print(urls)
        if let first = addingUrls.first {
            addingUrls.removeFirst()
            let _ = await prepare.createVideo(.init(string: first))
            if let next = addingUrls.first {
                return await addVideosDB(urls: next)

            } else {
                return true
            }
        } else {
            return true
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
