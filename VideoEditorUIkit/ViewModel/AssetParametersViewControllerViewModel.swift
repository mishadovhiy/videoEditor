//
//  AssetParametersViewControllerViewModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 11.01.2024.
//

import Foundation

struct AssetParametersViewControllerViewModel {
    var assetData:MovieGeneralParameterList = .test
    static var rowsHeight:CGFloat = 20
    static let durationWidthMultiplier:CGFloat = 15
    var scrollViewDeclaring = false
    
    var tableData:[MovieGeneralParameterList.AssetsData] {
        return assetData.asstes
    }
    var ignoreScroll:Bool = false
    var manualScroll = false
}
