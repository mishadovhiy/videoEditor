//
//  CGFloat.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.02.2024.
//

import Foundation

extension CGFloat {
    init(string:String?) {
        if let string,
           let number = NumberFormatter().number(from: string) {
            self.init(truncating: number)
        } else if let string, string != "" {
            self.init(Double(string) ?? 0)
        } else {
            self = 0
        }
    }
}

extension Double {
    
    func stringTime(_ format:DateComponentsFormatter.ZeroFormattingBehavior) -> String {
        let formatter = DateComponentsFormatter()
        var units:NSCalendar.Unit = [.minute, .second, .nanosecond]
        if self >= 3600 {
            units = [.hour, .minute, .second]
        }
        formatter.allowedUnits = units
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = format
        return formatter.string(from: TimeInterval(self)) ?? ""
    }
    
    /// creates string representing time from seconds
    var stringTime:String {
        return self.stringTime(.pad)
    }
}
