//
//  K.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

struct Constants {
    enum Images:String {
        case cancel = "cancel"
    }
    enum Color:String {
        case primaryBackground = "primaryBackground"
        case secondaryBackground = "secondaryBackground"
        case black = "black"
        case separetor = "separetor"
        case white = "white"
        case greyText = "greyText"
        case greyText6 = "greyText6"
        case lightSeparetor = "lightSeparetor"
        case overlay = "overlay"
        case darkYellow = "#908C58"
        case yellow = "#F7B500"
        case yellow1 = "#FFB400"//"#FFAB00"
        case yellow2 = "#EAD291"
        case orange = "#FF8900"
        case orange2 = "#E9B08A"
        case darkOrange = "#FA6400"
        case green = "#6DD400"
        case greenBlue = "#44D7B6"
        case blue = "#32C5FF"
        case darkBlue = "#0091FF"
        case purpure = "#6236FF"
        case purpure2 = "7435C5"
        case pinkPurpure = "#B620E0"
        case lightPink = "#C371DA"
        case lightPink1 = "#F99FFF"
        case pinkRed = "#FF2071"
        case clear = "clear"
        case red2 = "#E02020"
        case pink2 = "#C353E2"
        case pink3 = "#CF73E9"
        
        static var trackColor:UIColor {
            return .init(hex: "1D1D1D") ?? .red
            //.type(.secondaryBackground)
        }
    }
    
    enum Font:CGFloat {
        case small = 10
        case smallMedium = 10.1
        case regular = 12
        case regulatMedium = 12.2
        case primaryButton = 14
        case secondaryButton = 12.1
        
        var font:UIFont {
            switch self {
            case .small, .smallMedium:
                return .systemFont(ofSize: rawValue, weight: self == .small ? .regular : .medium)
            case .regular, .regulatMedium:
                return .systemFont(ofSize: rawValue, weight: self == .regulatMedium ? .medium : .regular)
            case .primaryButton, .secondaryButton:
                return .systemFont(ofSize: rawValue)
            }
        }
    }
}

extension Constants {
    struct Keys {
    }
}

extension Constants {
    
    enum VideoQualitySizes: Int, CaseIterable {
        case s480, s640x480, s640, s960x540, s1080, s1280, s1440, s1920, s3840
        
        var size: CGSize {
            return switch self {
            case .s480: .init(width: 480, height: 480)
            case .s640x480: .init(width: 640, height: 480)
            case .s640: .init(width: 640, height: 640)
            case .s960x540: .init(width: 960, height: 540)
            case .s1080: .init(width: 1080, height: 1080)
            case .s1280: .init(width: 1280, height: 1280)
            case .s1440: .init(width: 1440, height: 1440)
            case .s1920: .init(width: 1920, height: 1080)
            case .s3840: .init(width: 3840, height: 2160)
            }
        }
        
        var title: String {
            var result = "\(Int(size.width))x\(Int(size.height))"
            if self == .default {
                result.append(" (Default)")
            }
            return result
        }
        
        static var `default`: Self {
            .s1080
        }
        
    }
    
        
    enum VideoQuality:String, CaseIterable {
        case LowQuality
        case MediumQuality
        case HighestQuality
        case HEVCHighestQualityWithAlpha
        case s_640x480
        case s_960x540
        case s_1080x1080
        case s_1280x720
        case s_1920x1080
        case s_3840x2160
        case HEVC1920x1080
        case HEVC1920x1080WithAlpha
        case HEVC3840x2160
        case HEVC3840x2160WithAlpha
        case MVHEVC960x960
        case MVHEVC1440x1440
        case AppleM4A
        case Passthrough
        case AppleProRes422LPCM
        case AppleProRes4444LPCM
        
        var rowValueResult: String {
            var results = rawValue
            if rawValue.contains("s_") {
                results = results.replacingOccurrences(of: "s_", with: "")
            }
            return results
        }
        
        var title:String {
            let extensions = ["HEVC", "LPCM", "MVHEVC", "M4A"]
            var results = rowValueResult.addingSpaceBeforeUppercase
            extensions.forEach {
                results = results.replacingOccurrences(of: $0.addingSpaceBeforeUppercase, with: $0)
            }
            if self == .default {
                results.append(" (Default)")
            }
            return results
        }
        
        var allowedSized: [VideoQualitySizes] {
            let exceptions = self.exceptions
            var sizes = VideoQualitySizes.allCases
            exceptions?.forEach({ exp in
                sizes.removeAll(where: {
                    $0 == exp
                })
            })
            return sizes
        }
        
        var exceptions: [VideoQualitySizes]? {
            return switch self {
            case .AppleProRes4444LPCM: [
                    .s640, .s480, .s640x480, .s960x540
            ]
            default: nil
            }
        }
        
        var number:Int {
            var i = 0
            let size = self
            var selectedAt:Int?
            Constants.VideoQuality.allCases.forEach {
                if size == $0 {
                    selectedAt = i
                }
                i += 1
            }
            return selectedAt ?? Self.default.number
        }
        
        static var `default`: Self {
            return .HighestQuality
        }
    }
    
}
