//
//  Player.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import UIKit
import AVFoundation

class Player:AVPlayer {
    var pauseChanged:((_ pause:Bool)->())?
    override func pause() {
        super.pause()
        pauseChanged?(true)
    }
    
    override func play() {
        super.play()
        pauseChanged?(false)
    }
}
