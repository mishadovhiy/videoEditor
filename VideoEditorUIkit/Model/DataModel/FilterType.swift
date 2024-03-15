//
//  FilterType.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 15.03.2024.
//

import Foundation

enum FilterType:String {
    case none = "none"
    case invert = "CIColorInvert"
    case CIXRay = "CIXRay"
    case CIVignetteEffect = "CIVignetteEffect"
    case CIVignette = "CIVignette"
    case CIThermal = "CIThermal"
    case CISepiaTone = "CISepiaTone"
    case CIPhotoEffect = "CIPhotoEffect"
    case CIPalettize = "CIPalettize"
    case CIPaletteCentroid = "CIPaletteCentroid"
    case CIMinimumComponent = "CIMinimumComponent"
    case CIMaximumComponent = "CIMaximumComponent"
    case CIMaskToAlpha = "CIMaskToAlpha"
    case CILabDeltaE = "CILabDeltaE"
    case CIFalseColor = "CIFalseColor"
    case CIDocumentEnhancer = "CIDocumentEnhancer"
    case CIColorPosterize = "CIColorPosterize"
    case CIDither = "CIDither"
    case CIColorMonochrome = "CIColorMonochrome"
    case CIColorMap = "CIColorMap"
    case CIColorCurves = "CIColorCurves"
    case CIColorCubesMixedWithMask = "CIColorCubesMixedWithMask"
    case CIColorCubeWithColorSpace = "CIColorCubeWithColorSpace"
    case CIColorCube = "CIColorCube"
    case CIColorCrossPolynomial = "CIColorCrossPolynomial"
    
    var title:String {
        return rawValue
    }
    static let allCases:[Self] = [.none, .invert, .CIXRay, .CIVignetteEffect, .CIVignette, .CIThermal, .CISepiaTone, .CIPhotoEffect, .CIPalettize, .CIPaletteCentroid, .CIMinimumComponent, .CIMaximumComponent, .CIMaskToAlpha, .CILabDeltaE, .CIFalseColor, .CIDocumentEnhancer, .CIColorPosterize, .CIDither, .CIColorMonochrome, .CIColorMap, .CIColorCurves, .CIColorCubesMixedWithMask, .CIColorCubeWithColorSpace, .CIColorCube, .CIColorCrossPolynomial]
}
