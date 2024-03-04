//
//  test_MovieGeneralParameterList.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import Foundation

//MARK: test
extension MovieGeneralParameterList {
    static var test:Self {
        let texts:[RegularRow] = .test
        return .init(songs: .test, text: texts, media: .test, previewAssets: .test)
    }
}

extension [MovieGeneralParameterList.AssetsData] {
    static var test:Self {
        let mins: [CGFloat] = [2.5, 1.15, 5.54, 5.19, 10.04, 2.90]
       // let mins: [CGFloat] = [1.12, 1.12]
        return mins.compactMap({
            return .init(duration: $0 * 60, previews: .init(repeating: .init(), count: (Int($0) * 60) / 15))
        })
    }
}

extension [MovieGeneralParameterList.RegularRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (2.40, 100), (140, 50), (400, 20)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration)
        })
    }
}

extension [MovieGeneralParameterList.MediaRow] {
    static var test:Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (20.40, 200.50), (25.40, 15.50), (300.2, 15.2), (400, 100)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration, type: .random)
        })
    }
}

extension [MovieGeneralParameterList.SongRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (50, 300.50), (500.04, 90), (600, 12.9)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration)
        })
    }
}
