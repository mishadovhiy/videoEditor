//
//  ViewModelVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import Foundation
import AVFoundation

class EditorViewModel {
    var presenter:ViewModelPresenter?
    var videoTrack: AVMutableCompositionTrack?
    var audioTrack: AVMutableCompositionTrack?
    var model:TrackAppearenceModel? = TrackAppearenceModel(count: [.init(width: 10, title: "aa")])
    
    init(presenter:ViewModelPresenter) {
        self.presenter = presenter
        self.videoTrack = presenter.movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        self.audioTrack = presenter.movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    }
    
    deinit {
        presenter = nil
        videoTrack = nil
        audioTrack = nil
        model = nil
    }
    
    func addVideo() {
        Task {
            if await addTestVideos() {
                print(model?.movieData.count, " ihugfc")
                await presenter?.videoAdded()
            } else {
                await presenter?.errorAddingVideo()
            }
        }
    }
    
    @MainActor private func movie() -> AVMutableComposition {
        return presenter?.movie ?? .init()
    }
    
    @MainActor private func appendToMovieObzerver(_ newValue:TrackAppearence) {
        self.model?.movieData.append(newValue)
    }
    
    private func performAddVideo(url:String) async -> Bool {
        let movie = await movie()
        guard let url = Bundle.main.url(forResource: url, withExtension: "mov") else {
            fatalError()
        }
        let newMovie = AVURLAsset(url: url)
        do {
            let duration = try await newMovie.load(.duration)
            let range = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            print("duration ", duration.seconds)

            try await movie.insertTimeRange(range, of: newMovie, at: .zero)

            await self.appendToMovieObzerver(.init(width: duration.seconds, title: "\(duration.seconds)"))
            return true
        } catch let error {
            print(error.localizedDescription, " parformAddVideoparformAddVideo")
            return false
        }
    }
}


fileprivate extension EditorViewModel {
    private func addTestVideos() async -> Bool {
        let urls:[String] = ["1", "2"]

        for url in urls {
            let ok = await performAddVideo(url: url)
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
