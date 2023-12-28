//
//  TrackAppearenceModel.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import Foundation

struct TrackAppearence {
    let width:CGFloat
    let title:String
}

class TrackAppearenceModel: ObservableObject {

    @Published var movieData:[TrackAppearence] = [
        .init(width: 300, title: "some title"),
        .init(width: 600, title: "some title"),
        .init(width: 100, title: "some title")
    ]
    
    init() {
        self.movieData = []
    }
    
    init(count:[TrackAppearence]) {
        self.movieData = count
    }
    
    deinit {
        movieData.removeAll()
    }
}
