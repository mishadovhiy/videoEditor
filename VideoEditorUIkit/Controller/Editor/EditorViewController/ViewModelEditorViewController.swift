//
//  ViewModelEditorViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 08.03.2024.
//

import Foundation

struct ViewModelEditorViewController {
    var editorModel:EditorModel!
    var viewType:EditorViewType = .addingVideos
    
    init(editorPresenter:EditorModelPresenter) {
        editorModel = .init(presenter:editorPresenter)
    }
    mutating func `deinit`() {
        editorModel = nil
    }
    
    
    
    func mainEditorCollectionData(filterSelected:@escaping()->()) -> [EditorOverlayVC.OverlayCollectionData] {
        [
            .init(title: "Filter", toOverlay: .init(screenTitle: "Choose filter", collectionData: filterOptionsCollectionData(filterSelected)))
        ]
    }
    
    private func filterOptionsCollectionData(_ filterSelected:@escaping()->()) -> [EditorOverlayVC.OverlayCollectionData] {
        [
            .init(title: "invert colors", didSelect: {
                //update db
                
            })
        ]
    }
}

enum EditorViewType {
    case addingVideos
    case editing
}
