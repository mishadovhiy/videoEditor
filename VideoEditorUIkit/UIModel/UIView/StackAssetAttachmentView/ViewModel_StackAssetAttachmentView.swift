//
//  ViewModel_StackAssetAttachmentView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 01.05.2024.
//

import Foundation

struct ViewModelStackAssetAttachmentView {
    let type:InstuctionAttachmentType?
    
    public func createEmptyData(scroll: CGFloat) -> AssetAttachmentProtocol? {
        var newData = createEmptyData()
        
        newData?.time.start = 0
        if newData?.time.duration == 0 {
            newData?.time.duration = 0.2
        }
            newData?.time.start = scroll >= 1 ? 1 : (scroll <= 0 ? 0 : scroll)
        return newData
    }
    
    private func createEmptyData() -> AssetAttachmentProtocol? {
        switch type {
        case .text:
            return TextAttachmentDB(canSetDefault: true)
        case .song:
            return SongAttachmentDB()
        case .media:
            return ImageAttachmentDB(canSetDefault: true)
        default:
            return nil
        }
    }
}
