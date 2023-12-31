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
        return .init(songs: .test, text: .test, media: .test, asstes: .test)
    }
}

extension [MovieGeneralParameterList.AssetsData] {
    static var test:Self {
        let mins: [CGFloat] = [2.5, 1.15, 5.54]
        return mins.compactMap({
            return .init(duration: $0 * 60)
        })
    }
}

extension [MovieGeneralParameterList.RegularRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (2.40, 100)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration)
        })
    }
}

extension [MovieGeneralParameterList.MediaRow] {
    static var test:Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (20.40, 200.50)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration, type: .random)
        })
    }
}

extension [MovieGeneralParameterList.SongRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (50, 300.50)
        ]
        return data.compactMap({
            .init(inMovieStart: $0.start, duration: $0.duration)
        })
    }
}
