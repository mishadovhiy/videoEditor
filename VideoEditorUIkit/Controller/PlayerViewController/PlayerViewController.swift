//
//  PlayerViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 28.12.2023.
//

import UIKit
import AVFoundation
import Photos

protocol PlayerViewControllerPresenter {
    func addTrackPressed()
    func clearDataPressed()
    func reloadUI()
    func playTimeChanged(_ percent:CGFloat)
}

class PlayerViewController: PlayerSuperVC {
    
    fileprivate var preseter:PlayerViewControllerPresenter?
    var parentVC: EditorViewController? {
        return self.parent as? EditorViewController
    }
    
    override func loadView() {
        super.loadView()
        self.loadUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.subviews.forEach {
            $0.layer.zPosition = 999
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        preseter = nil
    }
    
    override func timeChanged(_ percent: CGFloat) {
        super.timeChanged(percent)
        preseter?.playTimeChanged(percent)
    }
    
    @objc fileprivate func addTrackPressed(_ sender:UIButton) {
        startRefreshing {
            self.pause()
            self.preseter?.addTrackPressed()
        }
    }
    
    @objc fileprivate func deletePressed(_ sender:UIButton) {
        startRefreshing {
            self.pause()
            self.preseter?.clearDataPressed()
        }
    }
    
    @objc fileprivate func reloadUIPressed(_ sender:UIButton) {
        startRefreshing {
            self.pause()
            self.preseter?.reloadUI()
        }
    }
}


// MARK: loadUI
fileprivate extension PlayerViewController {
    func loadUI() {
        addMovieButton()
        addDeleteAllButton()
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
        ])
    }
    
    private func addDeleteAllButton() {
        
        if let _ = view.subviews.first(where: {$0.layer.name == "deleteButton"}) {
            return
        }
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.layer.name = "deleteButton"
        view.addSubview(stack)
        
        let button = UIButton()
        button.setTitle("deleteAll", for: .normal)
        button.addTarget(self, action: #selector(self.deletePressed(_:)), for: .touchUpInside)
        stack.addArrangedSubview(button)
        
        let clearButton = UIButton()
        clearButton.setTitle("reload all", for: .normal)
        clearButton.addTarget(self, action: #selector(self.reloadUIPressed(_:)), for: .touchUpInside)
        stack.addArrangedSubview(clearButton)
        
        stack.addConstaits([
            .top:10, .left:10
        ])
    }
}


extension PlayerViewController {
    static func configure(_ presenter:PlayerViewControllerPresenter) -> PlayerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController ?? .init()
        vc.preseter = presenter
        return vc
    }
}
