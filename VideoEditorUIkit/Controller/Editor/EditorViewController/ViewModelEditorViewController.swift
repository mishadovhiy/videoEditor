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
}

enum EditorViewType {
    case addingVideos
    case editing
}
