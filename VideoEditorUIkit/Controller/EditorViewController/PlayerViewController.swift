//
//  PlayerViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import UIKit

class PlayerViewController: PlayerSuperVC {
    fileprivate var preseter:PlayerViewControllerPresenter?
    
    override func loadView() {
        super.loadView()
        addMovieButton()
    }
    
    @objc fileprivate func addTrackPressed(_ sender:UIButton) {
        preseter?.addTrackPressed()
    }
}


extension PlayerViewController {
    static func configure(_ presenter:PlayerViewControllerPresenter) -> PlayerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController ?? .init()
        vc.preseter = presenter
        return vc
    }
}


// MARK: loadUI
fileprivate extension PlayerViewController {
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
