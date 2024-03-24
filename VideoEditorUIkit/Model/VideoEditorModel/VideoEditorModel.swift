//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import UIKit
import AVFoundation
import Photos

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
    
    var movieDuration:Double = 0
    static let timeScale = CMTimeScale(NSEC_PER_SEC)
    static let fmp30 = CMTime(value: 1, timescale: 30)
    static var renderSize:CGSize = .init(width: 1080, height: 1080)//1920x1080
    static let exportPresetName: String = AVAssetExportPresetHEVCHighestQuality
    //AVAssetExportPresetHEVC1920x1080
    //AVAssetExportPresetHighestQuality
    //AVAssetExportPresetMediumQuality
    //AVAssetExportPreset640x480
    //AVAssetExportPresetHEVCHighestQuality
    
    
    func loadVideo(_ url:URL?, canShowError:Bool = true, videoAddedAction:Bool = true, needExport:Bool = false, canReload:Bool = false) {
        Task {
            let loadedMovie = await prepare.createVideo(url, needExport: needExport, setGeneralAudio: true)
            let db = DB.db.movieParameters
            self.dbParametersHolder = db.editingMovie
            if let url, videoAddedAction {
                await prepare.movieUpdated(movie: movieHolder, movieURL: url)
            }
            await checkVideoInstructions(videoAddedAction: videoAddedAction, canReload: canReload)
        }
    }
    
    func addVideo(force:Bool = false, url:URL?) {
        Task {
            let error = await prepare.createSaveVideo(url, addingVideo: true)
            if error == nil {
                await videoAdded()
            } else {
                await presenter?.errorAddingVideo(.init(title: "Video is not added", description: error?.messageContent?.title))
            }
        }
    }
    
    func addAttachmentPressed(_ data:AssetAttachmentProtocol?) {
        Task {
            if (DB.db.movieParameters.editingMovie?.filtered ?? false) {
                await presenter?.errorAddingVideo(.init(title: "Attachments cannot be added when after using filter", description: "set filter to text to modify attachments"))
                return
            }
            print("addingattachment: ", data)
            var added = false
            if let text = data as? TextAttachmentDB {
                DB.db.movieParameters.editingMovie?.texts.append(text)
                added = true
            } else if let image = data as? ImageAttachmentDB {
                DB.db.movieParameters.editingMovie?.images.append(image)
                added = true
            } else if let song = data as? SongAttachmentDB {
                added = true
                let wasUrl = DB.db.movieParameters.editingMovie?.songs
                DB.db.movieParameters.editingMovie?.songs = song
                await MainActor.run {
                    AppDelegate.shared?.fileManager?.tempSongURLHolder = .init(string: song.attachmentURL)
                }
                
                if let url = URL(string: song.attachmentURL), wasUrl?.attachmentURL ?? "" == "" {
                    await performAddSound(url:url)
                    return
                }
            }
            DB.db.movieParameters.editingMovie?.isOriginalUrl = true
            DB.db.movieParameters.needReloadLayerAttachments = true
            await presenter?.reloadUI()
        }
    }
    
    func addFilterPressed() {
        Task {
            DB.db.movieParameters.editingMovie?.isOriginalUrl = true
            DB.db.movieParameters.needReloadFilter = true
            DB.db.movieParameters.needReloadLayerAttachments = true
            await presenter?.reloadUI()
        }
    }
    
    func exportToLibraryPressed() {
        Task {
            self.movieHolder = self.movie
            let export = await prepare.export(asset:movie,videoComposition:nil, isVideo: false)
            guard let url = export.videoExportResponse?.url else {
                await presenter?.errorAddingVideo(.init(title: "Video not exported", description: export.error?.messageContent?.title))
                return
            }
            await MainActor.run {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { success, error in
                    if success {
                        print("Video saved to photo library")
                        Task {
                            await self.videoAdded(canReload:true)
                            await AppDelegate.shared?.coordinator?.showAlert(title: "Video has been exported\nSuccessfully", appearence: .type(.succsess))
                        }
                    } else {
                        print("Failed to save video to photo library:", error?.localizedDescription ?? "Unknown error")
                        Task {
                            await self.presenter?.errorAddingVideo(.init(title: error?.localizedDescription))
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        dbParametersHolder = nil
        movieHolder = nil
        _movie = nil
        presenter = nil
        prepare = nil
    }
}

fileprivate extension VideoEditorModel {
    private func performAddSound(url:URL?, canReload:Bool = false) async {
        let ok = await prepare.addSound(url:url)
        if let videoURL = ok.videoExportResponse {
            await MainActor.run {
                AppDelegate.shared?.fileManager?.tempSongURLHolder = url
            }
            if let component = videoURL.url?.lastPathComponent {
                DB.db.movieParameters.editingMovie?.notFilteredURL = component
            }
            await prepare.movieUpdated(movie: nil, movieURL: videoURL.url, canSetNil: false)
            await videoAdded(canReload: canReload)
        } else {
            print(ok.error?.messageContent, " erroraddinsong")
        }
    }
    
    func addSoundPressed(data:SongAttachmentDB?) {
        Task {
            if data?.attachmentURL ?? "" != "" {
                DB.db.movieParameters.editingMovie?.isOriginalUrl = true
                DB.db.movieParameters.needReloadLayerAttachments = true
                await presenter?.reloadUI()
            } else {
                await self.performAddSound(url: .init(string: data?.attachmentURL ?? ""))
            }
        }
    }
    
    private func addLayerAttachments(canReload:Bool = false) {
        print(movie?.duration ?? -3, " addText movie duration")
        Task {
            var hasValue = false
            if !(DB.db.movieParameters.editingMovie?.texts.isEmpty ?? true) {
                hasValue = true
            }
            if !(DB.db.movieParameters.editingMovie?.images.isEmpty ?? true) {
                hasValue = true
            }
            if !hasValue {
                await videoAdded(canReload: false)
                return
            }
            let ok = await self.prepare.addAttachments()
            if let _ = ok.response {
                await videoAdded(canReload: canReload)
            } else {
                await presenter?.errorAddingVideo(ok.error?.messageContent ?? .init(title: "Error adding text"))
            }
        }
    }
    
    private func videoAdded(canReload:Bool = true) async {
        movieDuration = await movie?.duration().seconds ?? 0
        if DB.db.movieParameters.editingMovie?.texts.count ?? 0 != 0 && canReload {
            await self.presenter?.reloadUI()
        } else {
            await presenter?.videoAdded()
        }
        movieHolder = nil
    }
    
    private func checkVideoInstructions(videoAddedAction:Bool = true, canReload:Bool = false) async {
        /// FA-956
        let needFilter = DB.db.movieParameters.needReloadFilter && (DB.db.movieParameters.editingMovie?.filter ?? .none) != FilterType.none
        if DB.db.movieParameters.needReloadLayerAttachments {
            DB.db.movieParameters.needReloadLayerAttachments = false
            DB.db.movieParameters.editingMovie?.isOriginalUrl = false
            if !(DB.db.movieParameters.editingMovie?.filtered ?? false) {
                let songUrl = await AppDelegate.shared?.fileManager?.tempSongURLHolder
                if songUrl == nil {
                    DB.db.movieParameters.editingMovie?.songs = .init()
                }
                addLayerAttachments()
                if let song = DB.db.movieParameters.editingMovie?.songs,
                   song.attachmentURL != "",
                   let songURL = songUrl ?? URL(string: song.attachmentURL) {
                    print(songUrl, " song url")
                    print(URL(string: song.attachmentURL), " trtewx")
                    await self.performAddSound(url: songURL, canReload: true)
                }
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
