//
//  ClickService.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import AudioToolbox
import UIKit

struct AudioToolboxService {
    func vibrate() {
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    func click() {
        AudioServicesPlaySystemSound(.init(1306))
    }
}
