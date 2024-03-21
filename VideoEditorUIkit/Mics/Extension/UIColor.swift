//
//  UIColor.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import UIKit

extension UIColor {
    static func type(_ type:Constants.Color) -> UIColor {
        return .init(type) ?? UIColor.red
    }
    
    convenience init?(_ colorConstrant:Constants.Color) {
        let row = colorConstrant.rawValue
        if row.contains("#") {
            self.init(hex: row)
        } else {
            self.init(named: colorConstrant.rawValue)
        }
    }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
    
    public convenience init?(hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            return nil
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    var toHex:String? {
        guard let components = self.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        let hexString = String(
            format: "%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)
        )
        return hexString
    }
    
    var isLight:Bool {
        var white: CGFloat = 0.0
        self.getWhite(&white, alpha: nil)
        print(white, " ujyrfecdwxs")
        return white > 0.65
    }
}
