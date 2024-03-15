//
//  AssetParametersViewControllerViewModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 11.01.2024.
//

import UIKit
import AVFoundation

class ViewModelEditorParametersViewController {
    var assetData:MovieGeneralParameterList = .test
    var editingAsset:AssetAttachmentProtocol?
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
    func assetChanged(_ asset:AVMutableComposition?, editorModel:EditorModel) async  {
        Task {
            assetData.text = DB.db.movieParameters.editingMovie?.texts ?? []
            let segments = await editorModel.prepare.loadSegments(asset: nil)
            assetData.previewAssets = segments.compactMap({
                return .create($0.0, composition: asset, loadPreviews: false)
            })
            await MainActor.run {
                self.reloadData?(false)
            }
            assetData.previewAssets = segments.compactMap({
                return .create($0.0, composition: asset, loadPreviews: true)
            })
            await MainActor.run {
                self.reloadData?(true)
            }
        }
    }
    
    func attachmentData(attachmentData:AssetAttachmentProtocol?) -> MovieAttachmentProtocol? {
        var data = attachmentData as? MovieAttachmentProtocol
        data?.inMovieStart = editingAsset?.inMovieStart ?? 0.2
        data?.duration = editingAsset?.duration ?? 0.6
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
