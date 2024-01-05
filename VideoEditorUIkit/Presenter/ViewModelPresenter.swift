//
//  ViewModelPresenter.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import Foundation
import AVFoundation

protocol ViewModelPresenter {
     @MainActor func videoAdded()
     @MainActor func errorAddingVideo()
    var movieURL:URL?{set get}
}
