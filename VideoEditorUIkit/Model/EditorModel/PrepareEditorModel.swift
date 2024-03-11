//
//  EditorLayerModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 05.01.2024.
//

import AVFoundation
import UIKit

class PrepareEditorModel {
    
    private var delegate:PrepareEditorModelDelegate!
    private let layerEditor:EditorVideoLayer
    
    init(delegate: PrepareEditorModelDelegate) {
        self.delegate = delegate
        self.layerEditor = .init()
    }
    
    deinit {
        delegate = nil
    }
    
    func export(asset:AVAsset, videoComposition:AVMutableVideoComposition?, isVideo:Bool, isQuery:Bool = false) async -> URL? {
        print("exportexporting ", asset.duration)
        guard let composition = delegate.movieHolder ?? delegate.movie
        else {
            print("Cannot create export session.")
            return nil
        }
        let export = AVAssetExportSession(composition: composition)
        let results = await export?.exportVideo(videoComposition: videoComposition)
        return results
    }
    
    
    func addText(data:MovieAttachmentProtocol) async -> Bool {
        let asset = delegate.movie ?? .init()
        print("start tefrgtref ", asset.duration)
        guard let composition = delegate.movie
        else { return false }
        let assetTrack = asset.tracks(withMediaType: .video)
        guard let firstTrack = assetTrack.first(where: {$0.naturalSize.width != 0}) else {
            return false
        }
        let videoSize = layerEditor.videoSize(assetTrack: firstTrack)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        layerEditor.addLayer(to: overlayLayer,
                             videoSize: videoSize,
                             text: .init(attachment: data), videoTotalTime: asset.duration.seconds)
        let videoComposition = await layerEditor.videoComposition(assetTrack: assetTrack, overlayLayer: overlayLayer, composition: composition)
        delegate.movieHolder = composition
        if let localUrl = await export(asset: composition, videoComposition: videoComposition, isVideo: false) {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
            return true
        } else {
            return false
        }
    }
    
    func createVideo(_ url:URL?, needExport:Bool = true) async -> URL? {
        let movie = delegate.movie ?? .init()
        guard let url else {
            return nil
        }
        print(movie.duration, " hyrgterfwedeg")
        let newMovie = AVURLAsset(url: url)//await createComposition(AVURLAsset(url: url))//AVURLAsset(url: url)
        //:AVMutableComposition = .init(url: url)
        print(newMovie.duration, " yhrtgerfewdw")
        guard newMovie.duration != .zero,
                let _ = await insertMovie(movie: newMovie, composition: movie) else {
            
            return nil
        }
        delegate.movieHolder = movie
        if needExport {
            guard let localUrl = await export(asset: movie, videoComposition: nil, isVideo: true) else {
                return nil
            }
            await self.movieUpdated(movie: movie, movieURL: localUrl)
            return localUrl
        } else {
            return nil
        }
    }
    
    func createVideo(_ url:String, addingVideo:Bool = false) async -> Bool {
        guard let url = Bundle.main.url(forResource: url, withExtension: "mov") ?? Bundle.main.url(forResource: url, withExtension: "mp4") else {
            return false
        }
        let urlResult = await self.createVideo(url)
        if addingVideo, let stringUrl = urlResult?.absoluteString {
            DB.db.movieParameters.editingMovie?.compositionURLs.append(stringUrl)
            DB.db.movieParameters.editingMovie?.originalURL = stringUrl
        }
        return urlResult != nil
    }
    
    private var filterAddedAction:((Bool)->())?
    
    func addFilter() async {
        let movie = delegate.movieHolder ?? delegate.movie!
        let video = VideoFilter.addFilter(composition: movie, completion: { url in
            Task {
                await self.filterAddedToComposition(url)
            }
        })
        
        if let localUrl = await export(asset: movie, videoComposition: video, isVideo: false) {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
        }
    }
    
    private func filterAddedToComposition(_ url:URL?) async {
        let movie = AVURLAsset(url: url!)
        if let localUrl = await export(asset: movie, videoComposition: nil, isVideo: false) {
            await self.movieUpdated(movie: nil, movieURL: localUrl, canSetNil: false)
            filterAddedAction?(true)
            filterAddedAction = nil
        } else {
            filterAddedAction?(false)
            filterAddedAction = nil
        }
    }

}


extension PrepareEditorModel {
    private func insertMovie(movie:AVURLAsset?, composition:AVMutableComposition) async -> AVMutableComposition? {
        guard let movie else {
            return nil
        }
        let duration = await movie.duration()
        print(duration, " createVideocreateVideoduration")
        movieDescription(movie: composition, duration: duration)
        
        do {
            if let _ = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) {
                let range = CMTimeRangeMake(start: .zero, duration: duration)
                try composition.insertTimeRange(range, of: movie, at: .zero)
                
                return composition
            } else {
                return nil
            }
            
        } catch {
            print(error.localizedDescription, " parformAddVideoparformAddVideo")
            return nil
        }
        movie.metadata.forEach {
            print("efdaefr ", $0)
        }
    }
    
    func loadSegments(asset:AVURLAsset?) async -> [(AVAssetTrackSegment, AVAssetTrack)] {
        guard let asset = asset ?? delegate.movie else {
            return []
        }
        var results:[(AVAssetTrackSegment, AVAssetTrack)] = []
        var id:[String] = []
        do {
            try await asset.load(.tracks).forEach {
                let track = $0
                let urlAsset = $0.asset as? AVURLAsset
                if $0.mediaType == .audio || $0.mediaType == .video && !id.contains(urlAsset?.url.absoluteString ?? "-1") {
                    if let url = urlAsset?.url.absoluteString {
                        id.append(url)
                    }
                    $0.segments.forEach {
                        results.append(($0, track))
                    }
                }
            }
            print("loaded segments count: ", results.count)
            return results
        } catch {
            print("Failed to insert track 1 into composition: \(error.localizedDescription)")
            return []
        }
    }
    
    private func createComposition(_ urlAsset:AVURLAsset) async -> AVMutableComposition? {
        let composition = AVMutableComposition()
        let segments = await loadSegments(asset: urlAsset)
        do {
            try segments.forEach {
                if let _ = composition.addMutableTrack(withMediaType: $0.1.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) {
                    let range = CMTimeRangeMake(start: $0.0.timeMapping.target.start, duration: $0.0.timeMapping.target.duration)
                    
                    try composition.insertTimeRange(range, of: $0.1.asset!, at: $0.0.timeMapping.target.start)
                }
                if let value = composition as? AVComposition
                {
                    let mutt = AVMutableVideoComposition(propertiesOf: composition)
                    
                    print(mutt.instructions, "fdasafwe")
                    mutt.instructions = []
                    composition.tracks.forEach {
                        let bb = AVMutableVideoComposition(propertiesOf: $0.asset!)
                        print(bb)
                        bb.instructions.removeAll()
                    }
                }
                urlAsset.metadata.forEach {
                    // composition.metadata.append($0)
                    
                    print($0.value, " erfwdwrf")
                }
            }
        } catch {
            print("error creating composition from url ", error)
            return nil
        }
        return composition
    }
    
    private func movieDescription(movie:AVMutableComposition, duration: CMTime) {
        var vids = 0
        movie.tracks.forEach {
            let mut = $0 as? AVMutableCompositionTrack
            vids += (mut?.asset?.tracks.count ?? 0)
            print("tracks: ", mut?.asset?.tracks)
            print(vids, " tregfewert")
            print(mut?.asset, " asset tgerfwrgt")
        }
        movie.tracks(withMediaType: .video).forEach {
            print($0.segments.count, " rtehytbrt")
            $0.segments.forEach {
                let time = $0.timeMapping.source
                print("startFromsd: ", time.start)
                print("startDuration: ", time.duration.seconds)
                
                print($0.description, " rtgerfegtr")
            }
        }
        print(vids, " rhtgefwergth")
        print(movie, " movie performAddVideo")
        print(duration, " duration createVideoaasdqw")
    }
}

extension PrepareEditorModel {
    @MainActor func movieUpdated(movie:AVMutableComposition?,
                                          movieURL:URL?,
                                          canSetNil:Bool = true
    ) {
        self.delegate.movie = movie
        self.delegate.movieURL = movieURL
    }
}

protocol PrepareEditorModelDelegate {
    var movie:AVMutableComposition? { get set }
    var movieHolder:AVMutableComposition?{ get set}
    var movieURL:URL? {get set}
}

