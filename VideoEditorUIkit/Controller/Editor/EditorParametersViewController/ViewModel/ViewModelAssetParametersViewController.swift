//
//  AssetParametersViewControllerViewModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 11.01.2024.
//

import UIKit
import AVFoundation

class EditorParametersVCViewModel {
    var assetData:MovieGeneralParameterList = .test
    var editingAsset:AssetAttachmentProtocol?
    /// used when cancel pressed, or to delete from db when done pressed
    var editingAssetHolder:AssetAttachmentProtocol?
    var editingView:UIView?
    static var rowsHeight:CGFloat = 20
    static let durationWidthMultiplier:CGFloat = 15
    var scrollViewDeclaring = false
    
    var tableData:[MovieGeneralParameterList.AssetsData] {
        return assetData.previewAssets
    }
    var ignoreScroll:Bool = false
    var manualScroll = false
    var reloadData:((Bool)->())?
    func assetChanged(_ asset:AVMutableComposition?, editorModel:VideoEditorModel) async  {
        Task {
            assetData.text = DB.db.movieParameters.editingMovie?.texts ?? []
            if DB.db.movieParameters.editingMovie?.songs.attachmentURL != "" {
                assetData.songs = [
                    DB.db.movieParameters.editingMovie?.songs ?? .init()
                ]
            } else {
                assetData.songs = []
            }
            assetData.songs.append(SongAttachmentDB.with({
                $0.selfMovie = true
            }))
            assetData.media = DB.db.movieParameters.editingMovie?.images ?? []
            let segments = try await editorModel.movie?.loadTracks(withMediaType: .video) ?? []
            assetData.previewAssets = segments.compactMap({
                return .create($0.segments.first!, composition: asset, loadPreviews: false)
            })
            await MainActor.run {
                self.reloadData?(false)
            }
            assetData.previewAssets = segments.compactMap({
                return .create($0.segments.first!, composition: asset, loadPreviews: true)
            })
            await MainActor.run {
                self.reloadData?(true)
            }
        }
    }
    
    func attachmentData(attachmentData:AssetAttachmentProtocol?) -> MovieAttachmentProtocol? {
        var data = attachmentData as? MovieAttachmentProtocol
        data?.time.start = editingAsset?.time.start ?? 0.2
        data?.time.duration = editingAsset?.time.duration ?? 0.6
        return data
    }
    
    deinit {
        assetData = .test
        reloadData = nil
    }
    
    func removeEditedAssetDB() {
        DB.db.movieParameters.editingMovie?.removeEditedAsset(editingAssetHolder)
        editingAssetHolder = nil
    }
}
