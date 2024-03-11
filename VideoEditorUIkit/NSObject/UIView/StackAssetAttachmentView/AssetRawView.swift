//
//  AssetRawView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

class AssetRawView:UIView {
    
    private var headerView:UIView? {
        self.subviews.first(where: {$0.layer.name == "Header" })
    }
    private var titleLabel:UILabel? {
        headerView?.subviews.first(where: {$0 is UILabel}) as? UILabel
    }
    private var pansGetsureView:[UIView] {
        self.subviews.filter({$0.layer.name == "panGestureView"})
    }
    
    private var xConstraint:NSLayoutConstraint? {
        superview?.constraints.first(where: {$0.firstAttribute == .left})
    }
    private var widthConstraint:NSLayoutConstraint? {
        superview?.constraints.first(where: {$0.firstAttribute == .width})
    }
    private let panNormalAlpha:CGFloat = 0.2

    var data:MovieAttachmentProtocol?
    private var editRowPressed:((_ row: MovieAttachmentProtocol?, _ view:AssetRawView?)->())?
    private var panEnded:((_ view:AssetRawView) -> ())?
    
    func updateView(data:MovieAttachmentProtocol?,
                    updateConstraints:Bool = true,
                    editRowPressed:@escaping(_ row: MovieAttachmentProtocol?, _ view:AssetRawView?)->(),
                    panEnded:@escaping(_ view:AssetRawView)->()
    ) {
        self.panEnded = panEnded
        self.data = data
        print(data, " etgrfwdawewfrg")
        self.editRowPressed = editRowPressed
        titleLabel?.text = data?.assetName ?? data?.defaultName
        self.backgroundColor = data?.color
        self.layer.zPosition = 999
        if updateConstraints {
            xConstraint!.constant = newConstraints.0
            widthConstraint!.constant = newConstraints.1
            self.layoutIfNeeded()
            self.layer.zPosition = 999
        } else {
            print("fvsdcaxz")
        }
    }
    
    private var newConstraints:(CGFloat, CGFloat) {
        let total = parentCollectionWidth ?? 100
        let x = total * data!.inMovieStart
        let width = total * data!.duration
        print(data?.assetName)
        (print(total * data!.inMovieStart, " evfrdasx ", data!.inMovieStart))
        print(total * data!.duration, " rtegfwedrgty ", data!.duration)
        return (x, width)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        data = nil
        editRowPressed = nil
    }
    
    func setSelected(_ selected:Bool) {
        layer.animationTransition()
        layer.borderColor = selected ? UIColor.orange.cgColor : UIColor.clear.cgColor
        layer.borderWidth = selected ? 5 : 0
        pansGetsureView.forEach {
            $0.isHidden = !selected
        }
       // self.layer.zPosition = selected ? 999 : 100
    }
    
    @objc private func editRowPressed(_ sender:UITapGestureRecognizer) {
        editRowPressed?(data, self)
        setSelected(true)
    }
    
    @objc private func panGesture(_ sender: UIPanGestureRecognizer) {
        let position = sender.translation(in: self)
        sender.setTranslation(.zero, in: self)
        print(position, " thyrtgerfed")
        if sender.view?.tag == 1 {
            xConstraint?.constant += position.x
            
        } else if sender.view?.tag == 0 {
            widthConstraint?.constant += position.x
        }
        superview?.layoutIfNeeded()
        self.layoutIfNeeded()
        subviews.forEach {
            $0.layoutIfNeeded()
        }
        if sender.state.isEnded {
            sender.view?.alpha = panNormalAlpha
            panEnded?(self)
        } else if sender.state == .began {
            sender.view?.alpha = 0.5
        }
    }
}

extension AssetRawView {
    static func create(superView:UIView?, 
                       data:MovieAttachmentProtocol?,
                       vcSuperView:UIView,
                       editRowPressed:@escaping(_ row: MovieAttachmentProtocol?, _ view:AssetRawView?)->(),
                       panEnded:@escaping(_ view:AssetRawView) -> (),
                       created:((_ newView:AssetRawView)->())? = nil
    ) {
        let new = AssetRawView()
        new.layer.name = data?.id.uuidString
        superView?.addSubview(new)
        new.data = data
        new.alpha = 0.5
        print("Dataasdsf: ", data)
        new.addConstaits([.left:new.newConstraints.0, .top:0, .width:new.newConstraints.1])
        new.heightAnchor.constraint(lessThanOrEqualToConstant: 30).isActive = true
        new.bottomAnchor.constraint(lessThanOrEqualTo: new.superview!.bottomAnchor).isActive = true
        new.createHeader(vcSuperView: vcSuperView)
        new.updateView(data: data, updateConstraints: false, editRowPressed: editRowPressed, panEnded: panEnded)
        new.createPans()
        new.layer.cornerRadius = 7
        //new.layer.zPosition = 100
        created?(new)
    }
    
    private func createHeader(vcSuperView:UIView) {
        let headerView = UIView()
        headerView.layer.name = "Header"
        self.addSubview(headerView)
        headerView.addConstaits([.left:0, .top:0, .bottom:0, .right:0])
        headerView.leadingAnchor.constraint(greaterThanOrEqualTo: vcSuperView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        let label:UILabel = .init()
        label.adjustsFontSizeToFitWidth = true
        headerView.addSubview(label)
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0])
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editRowPressed(_:))))
    }
    
    private func createPans() {
        [false, true].forEach {
            createPan(isRight: $0)
        }
    }
    
    private func createPan(isRight:Bool = false) {
        let view = UIView()
        view.backgroundColor = .red
        view.alpha = panNormalAlpha
        view.tag = isRight ? 1 : 0
        view.isUserInteractionEnabled = true
        view.layer.name = "panGestureView"
        view.isHidden = true
        self.addSubview(view)
        view.addConstaits(isRight ? [
            .leading:0, .top:0, .bottom:0, .trailing: -50
        ] : [
            .trailing:0, .top:0, .bottom:0, .width:40
        ])
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
    }
        
    final private var parentScrollView:UIScrollView? {
        return parentCollectionView?.superview?.superview as? UIScrollView
    }
    
    final private var parentCollectionWidth:CGFloat? {
        return parentCollectionView?.constraints.first(where: {$0.identifier == "collectionWidth"})?.constant ?? (UIApplication.shared.keyWindow?.frame.width ?? 100)
    }
    
    private var parentCollectionView:UICollectionView? {
        let stackView = self.superview?.superview as? UIStackView
        let topStackView =  stackView?.superview?.superview as? UIStackView
        return topStackView?.subviews.first(where: {$0 is UICollectionView}) as? UICollectionView
    }
}
