//
//  EditingOvarlayVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 04.03.2024.
//

import UIKit

class EditorOverlayVC: UIViewController {

    @IBAction func addPressed(_ sender: UIButton) {
        
    }
    @IBAction func closePressed(_ sender: UIButton) {
        
    }
    
}

extension EditorOverlayVC {
    static func configure() -> EditorOverlayVC {
        let vc = UIStoryboard(name: "Reusable", bundle: nil).instantiateViewController(withIdentifier: "EditorOverlayVC") as? EditorOverlayVC ?? .init()
        return vc
    }
}
