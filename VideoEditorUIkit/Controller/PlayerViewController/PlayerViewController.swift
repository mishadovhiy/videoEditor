//
//  PlayerViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import UIKit
import AVFoundation
import Photos
class PlayerViewController: PlayerSuperVC {
    fileprivate var preseter:PlayerViewControllerPresenter?
    
    override func loadView() {
        super.loadView()
        self.loadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        preseter = nil
    }
    
    override func timeChanged(_ percent: CGFloat) {
        super.timeChanged(percent)
        preseter?.playTimeChanged(percent)
    }
    
    override func preparePlayer() {
        super.preparePlayer()

    }
    
    @objc fileprivate func addTrackPressed(_ sender:UIButton) {
        preseter?.addTrackPressed()
    }
}


// MARK: loadUI
fileprivate extension PlayerViewController {
    func loadUI() {
        addMovieButton()
    }
    
    private func addMovieButton() {
        if let _ = view.subviews.first(where: {$0.layer.name == "addButton"}) {
            return
        }
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(self.addTrackPressed(_:)), for: .touchUpInside)
        button.layer.name = "addButton"
        view.addSubview(button)
        button.addConstaits([
            .bottom:10, .left:10
        ], superView: view)
    }
}



extension PlayerViewController {
    static func configure(_ presenter:PlayerViewControllerPresenter) -> PlayerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController ?? .init()
        vc.preseter = presenter
        return vc
    }
}
