//
//  SongAttachmentDB.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation
import UIKit

struct SongAttachmentDB {
    
    var dict:[String:Any] = [:]
    var attachmentType: InstuctionAttachmentType? = .song
    var id: UUID = .init()
    
    var attachmentURL:String {
        get {
            return dict["attachmentURL"] as? String ?? ""
        }
        set {
            dict.updateValue(newValue, forKey: "attachmentURL")
        }
    }
    
    var selfMovie:Bool = false
}

// MARK: - AssetAttachmentProtocol
extension SongAttachmentDB:AssetAttachmentProtocol {
    /// 0..<1
    var volume: CGFloat {
        get {
            if let size = dict["volume"] as? String {
                return .init(string: size)
            } else {
                return 1
            }
        }
        set {
            dict.updateValue(String.init(value: newValue), forKey: "volume")
        }
    }
    
    
    var defaultName: String {
        attachmentType?.rawValue ?? "?"
    }
    var color: UIColor {
        return .type(selfMovie ? .lightPink1 : .purpure)
    }
    
    var time: DB.DataBase.MovieParametersDB.AssetTime {
        get {
            return .with({
                $0.duration = 1
                $0.start = 0
            })//.init(dict: dict["time"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "time")
        }
    }
    
    var trackColor: UIColor {
        return color
    }
    
    var assetName: String? {
        get {
            return URL(string: attachmentURL)?.lastPathComponent ?? "Video Valume"
        }
        set {
            if let newValue {
                dict.updateValue(newValue, forKey: "assetName")
            } else {
                dict.removeValue(forKey: "assetName")
            }
        }
    }
}

// MARK: - Equatable
extension SongAttachmentDB:Equatable {
    static func == (lhs: SongAttachmentDB, rhs: SongAttachmentDB) -> Bool {
        return lhs.assetName == rhs.assetName &&
        lhs.time == rhs.time
    }
}

// MARK: - configure
extension SongAttachmentDB {
    public static func with(
        _ populator: (inout Self) throws -> ()
    ) rethrows -> Self {
        var message = Self(dict: [:])
        try populator(&message)
        return message
    }
}
