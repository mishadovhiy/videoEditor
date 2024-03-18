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
            let originalUrl = db.editingMovie?.forceOriginalURL ?? ""
            let notFilteredURL = db.editingMovie?.notFilteredURL ?? ""
            let editingUrl = db.editingMovieURL ?? ""
            try contents.forEach({
                let cantRemove = $0.absoluteString.contains(originalUrl) || $0.absoluteString.contains(notFilteredURL) || $0 == exept || ($0.absoluteString.contains(editingUrl) && exept != nil)
                if exept == nil || !cantRemove {
                    try fileManager.removeItem(at: $0)
                    print("Removed: \($0.lastPathComponent)")
                }
            })
        } catch {
            print("Error: \(error)")
        }
    }
}
