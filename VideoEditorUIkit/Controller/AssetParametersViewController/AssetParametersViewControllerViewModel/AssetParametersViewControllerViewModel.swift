//
//  AssetParametersViewControllerViewModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 11.01.2024.
//

import Foundation
import AVFoundation

class AssetParametersViewControllerViewModel {
    var assetData:MovieGeneralParameterList = .test
    static var rowsHeight:CGFloat = 20
    static let durationWidthMultiplier:CGFloat = 15
    var scrollViewDeclaring = false
    
    var tableData:[MovieGeneralParameterList.AssetsData] {
        return assetData.previewAssets
    }
    var ignoreScroll:Bool = false
    var manualScroll = false
    var reloadData:(()->())?
    func assetChanged(_ asset:AVMutableComposition?) async  {
        Task {
            assetData.text = DB.db.movieParameters.editingMovie?.texts ?? []
            let tracks = asset?.tracks(withMediaType: .video)
            assetData.previewAssets = tracks?.first?.segments.compactMap({
                return .create($0, composition: asset)
            }) ?? []
            print(assetData.previewAssets.count, " rgtefrsr")
            print(assetData.duration, " tyrefdw")
            await MainActor.run {
                self.reloadData?()
            }
        }
    }
}
