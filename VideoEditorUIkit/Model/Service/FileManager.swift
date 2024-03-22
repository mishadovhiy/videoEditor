//
//  FileManager.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import UIKit

struct FileManagerServgice {
    
    private let manager:FileManager
    private let url: URL
    var tempSongURLHolder:URL?
    
    init() {
        manager = FileManager.default
        url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
    
    var contents:[URL]? {
        let fileManager = manager
        let tempDirectoryURL = url
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
            return contents
            
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func clearDirectory(_ exept:URL?) {
        let db = DB.db.movieParameters
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
            var ignore = exept == nil ? [] : db.ignoreClearUrls
            if exept != nil {
                ignore.append(db.editingMovie?.forceOriginalURL ?? "")
                ignore.append(db.editingMovieURL ?? "")
            }
            try contents.forEach({ url in
                let cantRemove = ignore.contains {
                    url.absoluteString.contains($0)
                } && exept != nil
                if exept == nil || !cantRemove {
                    try fileManager.removeItem(at: url)
                    print("Removed: \(url.lastPathComponent)")
                }
            })
        } catch {
            print("Error: \(error)")
        }
    }
}
