//
//  AVAsset.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import AVFoundation

extension AVAsset {
    func duration() async -> CMTime {
        do {
            return try await load(.duration)
        } catch {
            return .invalid
        }
    }
}
