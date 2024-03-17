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
        return .init(songs: [], text: [], media: [], previewAssets: [])
    }
}

extension [MovieGeneralParameterList.AssetsData] {
    static func test(type:InstuctionAttachmentType) -> Self {
        let mins: [CGFloat] = [2.5, 1.15, 5.54, 5.19, 10.04, 2.90]
        return mins.compactMap({ min in
            let repeatCount = (Int(min) * 60) / 15
            return .with(type: type) {
                $0.time = .with({
                    $0.duration = min
                })
                $0.previews = .init(repeating: .init(), count: repeatCount)
            }
        })
    }
}

extension [MovieGeneralParameterList.RegularRow] {
    static func test(type:InstuctionAttachmentType) -> Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (2.40, 100), (140, 50), (400, 20)
        ]
        return data.compactMap({ row in
                .with(type: type, {
                    $0.time = .with({
                        $0.start = row.start
                        $0.duration = row.duration
                    })
                })
        })
    }
}

extension [MovieGeneralParameterList.MediaRow] {
    static var test:Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (20.40, 200.50), (25.40, 15.50), (300.2, 15.2), (400, 100)
        ]
        return data.compactMap({ row in
                .with {
                    $0.time = .with({
                        $0.start = row.start
                        $0.duration = row.duration
                    })
                }
        })
    }
}

extension [MovieGeneralParameterList.SongRow] {
    static var test: Self {
        let data:[(start:CGFloat, duration:CGFloat)] = [
            (0.5, 0.3), (0.2, 0.3), (0.06, 0.25)
        ]
        return data.compactMap({ row in
                .with {
                    $0.time = .with({
                        $0.start = row.0
                        $0.duration = row.1
                    })
                }
        })
    }
}
