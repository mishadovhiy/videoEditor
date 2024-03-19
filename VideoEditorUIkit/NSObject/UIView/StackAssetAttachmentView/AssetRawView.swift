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
        constraints.first(where: {$0.firstAttribute == .width})
    }
    private let clickService = AudioToolboxService()
    private let panNormalAlpha:CGFloat = 0.2
    var canSelect = true
    var isSelected:Bool = false
    var isEditing:Bool = true
    var data:AssetAttachmentProtocol?
    private var editRowPressed:((_ row: AssetAttachmentProtocol?, _ view:AssetRawView?)->())?
    private var panEnded:((_ view:AssetRawView) -> ())?
    
    func updateView(data:AssetAttachmentProtocol?,
                    updateConstraints:Bool = true,
                    editRowPressed:@escaping(_ row: AssetAttachmentProtocol?, _ view:AssetRawView?)->(),
                    panEnded:@escaping(_ view:AssetRawView)->()
    ) {
        self.panEnded = panEnded
        self.data = data
        print(data.debugDescription, " data ")
        self.editRowPressed = editRowPressed
        titleLabel?.text = data?.assetName ?? data?.defaultName
        self.backgroundColor = data?.color
        self.layer.zPosition = 999
        if updateConstraints {
            xConstraint!.constant = newConstraints.0
            widthConstraint!.constant = newConstraints.1
            self.layoutIfNeeded()
            self.layer.zPosition = 999
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            return super.isUserInteractionEnabled
        }
        set {
            if isSelected {
                super.isUserInteractionEnabled = true
                return
            }
            super.isUserInteractionEnabled = newValue
        }
    }
    
    private var newConstraints:(CGFloat, CGFloat) {
        let total = parentCollectionWidth ?? 100
        let x = total * data!.time.start
        let width = total * data!.time.duration
        return (x, width)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        data = nil
        editRowPressed = nil
    }
    
    func setSelected(_ selected:Bool, deselectAll:Bool = false) {
        canSelect = selected ? true : !deselectAll
        isSelected = selected
        
        isUserInteractionEnabled = super.isUserInteractionEnabled
        layer.opacity = canSelect ? (selected ? 1 : 0.8) : 0.2
        layer.borderColor = selected ? UIColor.orange.cgColor : UIColor.clear.cgColor
        layer.borderWidth = selected ? 1 : 0
        pansGetsureView.forEach {
            $0.isHidden = !selected
        }
        self.layer.zPosition = selected ? 999 : 2
    }
    
    @objc private func editRowPressed(_ sender:UITapGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        if isSelected || !canSelect {
            return
        }
        setSelected(true)
        editRowPressed?(data, self)
    }
    
    @objc private func panGesture(_ sender: UIPanGestureRecognizer) {
        if !isSelected {
            return
        }
        let position = sender.translation(in: self)
        print("testsfd: ", (widthConstraint?.constant ?? 0) + position.x)
        if sender.view?.tag == 1 {
            xConstraint?.constant += position.x
        } else if sender.view?.tag == 0 {
            widthConstraint!.constant += position.x
        }
        superview?.layoutIfNeeded()
        layoutIfNeeded()
        subviews.forEach {
            $0.layoutIfNeeded()
        }
        sender.setTranslation(.zero, in: self)
        if sender.state.isEnded {
            panEnded?(self)
        }
        gestureBegun(!sender.state.isEnded, senderView: sender.view)
        clickService.vibrate()
    }

    private func gestureBegun(_ begun:Bool, senderView:UIView?) {
        let animation = UIViewPropertyAnimator(duration: 0.19, curve: .easeInOut) {
            senderView?.alpha = begun ? 0.5 : self.panNormalAlpha
            if (senderView?.tag ?? 0) != 0 {
                self.layer.move(.top, value: begun ? -5 : 0)
            }
        }
        animation.startAnimation()
    }
}

extension AssetRawView {
    static func create(superView:UIView?, 
                       data:AssetAttachmentProtocol?,
                       vcSuperView:UIView,
                       editRowPressed:@escaping(_ row: AssetAttachmentProtocol?, _ view:AssetRawView?)->(),
                       panEnded:@escaping(_ view:AssetRawView) -> (),
                       created:((_ newView:AssetRawView)->())? = nil
    ) {
        let new = AssetRawView()
        new.layer.name = data?.id.uuidString
        superView?.addSubview(new)
        new.data = data
        new.alpha = 0.8
        new.addConstaits([.left:new.newConstraints.0, .top:0, .width:new.newConstraints.1])
        new.heightAnchor.constraint(lessThanOrEqualToConstant: 30).isActive = true
        new.bottomAnchor.constraint(lessThanOrEqualTo: new.superview!.bottomAnchor).isActive = true
        new.createHeader(vcSuperView: vcSuperView)
        new.updateView(data: data, updateConstraints: false, editRowPressed: editRowPressed, panEnded: panEnded)
        new.createPans()
        new.layer.cornerRadius = 7
        created?(new)
    }
    
    private func createHeader(vcSuperView:UIView) {
        let headerView = UIView()
        headerView.layer.name = "Header"
        self.addSubview(headerView)
        headerView.addConstaits([.left:0, .top:0, .bottom:0, .right:0])
        
        if let _ = superview?.superview?.subviews.first(where: {$0.layer.name == "LeftHeaderView"}) {
            headerView.leadingAnchor.constraint(greaterThanOrEqualTo: vcSuperView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        } else {
            headerView.leadingAnchor.constraint(greaterThanOrEqualTo: vcSuperView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        }
        let label:UILabel = .init()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .init(.white)
        label.font = .type(.smallMedium)
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
