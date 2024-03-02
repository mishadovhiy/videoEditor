//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

protocol ViewModelPresenter {
     @MainActor func videoAdded()
     @MainActor func errorAddingVideo()
    var movieURL:URL?{set get}
    @MainActor func deleteAllData()
}

class EditorModel {
    var presenter:ViewModelPresenter?
    var prepare:PrepareEditorModel!
    var _movie:AVMutableComposition?
    private var dbParametersHolder:DB.DataBase.MovieParametersDB.MovieDB?
    
    init(presenter:ViewModelPresenter) {
        self.presenter = presenter
        self.prepare = .init(delegate: self)
    }
    
    deinit {
        _movie = nil
        prepare.delegate = nil
        presenter = nil
    }
    
    static let timeScale = CMTimeScale(NSEC_PER_SEC)
    static let fmp30 = CMTime(value: 1, timescale: 30)
    
    func addText(_ data:MovieAttachmentProtocol, canAddToDB:Bool = true) {
        Task {
            if let dbData = data as? TextAttachmentDB,
               canAddToDB
            {
                DB.db.movieParameters.editingMovie?.texts.append(dbData)
            }
            if await self.prepare.addText(data: data) {
                await videoAdded()
            } else {
                //await presenter?.errorAddingVideo()
                await videoAdded()
            }
        }
    }
    
    func loadVideo(_ url:URL?, canShowError:Bool = true) {
        Task {
            if await prepare.createVideo(url) {
                await addAllDB()
                await presenter?.videoAdded()
            } else {
                if canShowError {
                    await presenter?.errorAddingVideo()
                } else {
                    self.addVideo()
                }
            }
        }
    }
    
    func addVideo() {
        Task {
            if await addTestVideos() {
                await videoAdded()
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
}

//MARK: db
fileprivate extension EditorModel {
    private func videoAdded() async {
        if DB.db.movieParameters.editingMovie?.texts.count ?? 0 != 0 {
            await self.presenter?.deleteAllData()
        } else {
            await presenter?.videoAdded()
        }
    }
    func addAllDB() async {
        self.dbParametersHolder = DB.db.movieParameters.editingMovie
        await addDBTexts()
//        if let first = DB.db.movieParameters.editingMovie?.texts.first {
//            if await self.prepare.addText(data: first) {
//                await presenter?.videoAdded()
//            } else {
//                await presenter?.videoAdded()
//            }
//        }
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


//MARK: test
fileprivate extension EditorModel {
    private func addTestVideos() async -> Bool {
        let urls:[String] = ["1"]
        for url in urls {
            let ok = await prepare.createVideo(url)
            if ok {
                if url == urls.last {
                    return true
                }
            } else {
                return false
            }
        }
        return false
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
