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
}

// MARK: - AssetAttachmentProtocol
extension SongAttachmentDB:AssetAttachmentProtocol {
    
    var defaultName: String {
        attachmentType?.rawValue ?? "?"
    }
    var color: UIColor {
        return .purple
    }
    
    var time: DB.DataBase.MovieParametersDB.AssetTime {
        get {
            return .init(dict: dict["time"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "time")
        }
    }
    
    var assetName: String? {
        get {
            dict["assetName"] as? String ?? "-"
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
