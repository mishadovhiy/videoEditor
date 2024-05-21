//
//  ClickService.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import AudioToolbox
import UIKit
import CoreHaptics

class AudioToolboxService {
    private var engine: CHHapticEngine?
    init() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            engine = nil
            print("Error initializing haptic engine: \(error.localizedDescription)")
        }
    }
    
    deinit {
        engine = nil
    }
    
    func vibrate(_ style:VibrationStyle = .default) {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: style == .error ? 0.9 : (style == .default ? 0.4 : 0.2))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: style == .error ? 0.3 : 0.1)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.1)
        guard let pattern = try? CHHapticPattern(events: [event], parameters: []) else {
            print("cantvibrate")
            return
        }
        let player = try? engine?.makePlayer(with: pattern)
        
        do {
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Error playing haptic: \(error.localizedDescription)")
        }
    }
    
    enum VibrationStyle {
        case error
        case `default`
        case short
    }
    
    func click() {
        AudioServicesPlaySystemSound(.init(1306))
    }
}
