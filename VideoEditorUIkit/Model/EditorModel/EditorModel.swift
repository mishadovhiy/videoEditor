//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation

class EditorModel {
    var presenter:ViewModelPresenter?
    var prepare:PrepareEditorModel!
    var _movie:AVMutableComposition?
    
    init(presenter:ViewModelPresenter) {
        self.presenter = presenter
        self.prepare = .init(delegate: self)
    }
    
    deinit {
        presenter = nil
    }
    
    
    func addVideo(text:Bool) {
        Task {
            if await addTestVideos() {
                await presenter?.videoAdded()
                
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
    
    
    func addText() {
        Task {
            if await self.prepare.addText() {
                await presenter?.videoAdded()
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
}


//MARK: test
fileprivate extension EditorModel {
    
    private func addTestVideos() async -> Bool {
        let urls:[String] = ["1", "2"]
        for url in urls {
            let ok = await prepare.addVideo(url)
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
