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
            await MainActor.run {
                self.reloadData?()
            }
        }
    }
}
