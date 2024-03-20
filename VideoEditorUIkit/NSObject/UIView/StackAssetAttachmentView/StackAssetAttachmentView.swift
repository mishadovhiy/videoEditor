//
//  AssetAttachmentView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit
protocol AssetAttachmentViewDelegate {
    func attachmentSelected(_ data:AssetAttachmentProtocol?, view:UIView?)
    func attachmentPanChanged(view:AssetRawView?)
    var vc:UIViewController { get }
}

class StackAssetAttachmentView:UIView {
    var mediaType:InstuctionAttachmentType?
    private var data:[AssetAttachmentProtocol] = []
    private var delegate:AssetAttachmentViewDelegate?
    var attachmentType:InstuctionAttachmentType? {
        return data.first?.attachmentType ?? mediaType
    }
    
    private var layerStack:UIStackView? {
        return self.subviews.first(where: {$0 is UIStackView}) as? UIStackView
    }
    
    private var leftHeaderView:UIView? {
        layerStack?.subviews.first(where: {$0.layer.name == "LeftHeaderView"})
    }
    
    private var isSelected = false
    private let audioBox = AudioToolboxService()
    private var canAddNew:Bool {
        if attachmentType == .song && data.count == 2 {
            return false
        } else {
            return true
        }
    }
    // MARK: - Life-Cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                self.loadUI()
            })
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        delegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if superview == nil {
            return
        }
        updateLayers()
    }
    
    func deselectAll() {
        setSelected(false)
        layerStack?.arrangedSubviews.forEach( {
            $0.subviews.forEach {
                if let rowView = $0 as? AssetRawView {
                    rowView.setSelected(false, deselectAll: true)
                }
            }
        })
    }
    
    func addEmptyPressed() {
        var newData:AssetAttachmentProtocol?
        switch attachmentType {
        case .text:
            newData = TextAttachmentDB()
        case .song:
            newData = SongAttachmentDB()
        case .media:
            newData = ImageAttachmentDB()
        default:
            break
        }
        newData?.time.start = 0
        if newData?.time.duration == 0 {
            newData?.time.duration = 0.2
        }
        if let superView = (delegate as? EditorParametersViewController)?.scrollView {
            let superLeftSpace = EditorParametersViewController.collectionViewSpace
            let scroll = (superView.contentOffset.x + superLeftSpace.x) / (superView.contentSize.width + (superLeftSpace.x * 2))
            newData?.time.start = scroll >= 1 ? 1 : (scroll <= 0 ? 0 : scroll)
        }
        guard let newData else {
            return
        }
        self.setSelected(true)
        addRowView(data: newData, isEmpty: true) { view in
            view.layer.name = "isEmptyView"
            view.isEditing = false
            view.alpha = 0
            view.layer.zoom(value: 0.7)
            self.editRowPressed(newData, view: view, force: true)
            view.setSelected(true)
            self.setEmptyViewHidden(false, view: view)
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
            layerStack?.arrangedSubviews.forEach({
                $0.subviews.forEach {
                    $0.isUserInteractionEnabled = newValue
                }
            })
        }
    }
    
    // MARK: @IBAction
    private func editRowPressed(_ data:AssetAttachmentProtocol?, view:AssetRawView? = nil, force:Bool = false) {
        if isSelected && !force {
            return
        }
        print(tag, " grfedretghyytgrfv")
        delegate?.attachmentSelected(data, view: view ?? self)
        setSelected(true)
    }
    
    private func assetChangePanEnded(_ view:AssetRawView?) {
        delegate?.attachmentPanChanged(view:view)
    }
    
    @objc private func emptyRowPressed(_ sender:UITapGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        if isSelected {return}
        if !canAddNew {
            audioBox.vibrate(style: .rigid)
            return
        }
        addEmptyPressed()
    }
}

// MARK: - updateUI
extension StackAssetAttachmentView {
    public func updateView(_ data:[AssetAttachmentProtocol]? = nil) {
        updateSuperViews()
        if let data {
            self.data = data
        }
        guard let _ = self.layerStack else {
            return
        }
        data?.forEach({
            self.addRowView(data: $0)
        })
    }
    
    private func addRowView(data:AssetAttachmentProtocol, isEmpty:Bool = false, created:((_ view:AssetRawView)->())? = nil) {
        let layer = isEmpty ? 0 : self.data.layerNumber(item: data)
        if let layer,
           let toView = layerStack?.arrangedSubviews[layer] {
            AssetRawView.create(superView: toView, data: data, vcSuperView: delegate!.vc.view, editRowPressed: {row,view in 
                self.editRowPressed(row, view:view)
            }, panEnded: assetChangePanEnded(_:), created:created)
            toView.isHidden = false
        } else {
            print("error adding row to the \(String(describing: Self.self))  ", layer ?? -3)
        }
    }
    
    private func updateSuperViews() {
        layerStack?.arrangedSubviews.forEach({
            $0.subviews.forEach {
                if $0.layer.name != "LeftHeaderView" {
                    $0.removeFromSuperview()
                }
            }
        })
    }
    
    func setSelected(_ selected:Bool) {
        isSelected = selected
        isUserInteractionEnabled = super.isUserInteractionEnabled
        layer.animationTransition(0.2)
        layer.borderColor = selected ? UIColor.white.withAlphaComponent(0.2).cgColor : UIColor.clear.cgColor
        layer.borderWidth = selected ? 1 : 0
        if !selected,
           let view = layerStack?.arrangedSubviews.first(where: {
               $0.subviews.contains(where: {$0.layer.name == "isEmptyView"})})?.subviews.first(where: {
                   $0.layer.name == "isEmptyView"
               })
        {
            setEmptyViewHidden(true, view: view) {
                view.removeFromSuperview()
            }
        }
        layerStack?.arrangedSubviews.forEach({
            if let first = $0.subviews.first(where: {$0 is AssetRawView}) as? AssetRawView {
                first.setSelected(false, deselectAll: false)
            }
        })
    }
    
    private func setEmptyViewHidden(_ hidden:Bool, view:UIView, completion:(()->())? = nil) {
        view.isUserInteractionEnabled = !hidden
        let animation = UIViewPropertyAnimator(duration: hidden ? 0.5 : 0.25, curve: .easeInOut) {
            view.alpha = hidden ? 0 : 1
            view.layer.zoom(value: hidden ? 0.7 : 1)
        }
        animation.addCompletion { _ in
            completion?()
        }
        animation.startAnimation()
    }
}

// MARK: - loadUI
fileprivate extension StackAssetAttachmentView {
    func loadUI() {
        if layerStack != nil {
            self.updateView(self.data)
            return
        }
        let layerStack:UIStackView = .init()
        layerStack.axis = .vertical
        layerStack.distribution = .fillEqually
        addSubview(layerStack)
        for i in 0..<(attachmentType == .song ? 2 : 5) {
            let view = UIView()
            view.isHidden = true
            view.tag = i
            layerStack.addArrangedSubview(view)
        }
        layerStack.addConstaits([.left:0, .right:0, .top:0, .bottom:0])
        print(data, " grefgtyh")
        self.updateView(self.data)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyRowPressed(_:))))
        self.backgroundColor = Constants.Color.trackColor
        loadLeftHeader()
    }
    
    func loadLeftHeader() {
        let newView = UIView()
        layerStack?.addSubview(newView)
        
        newView.tag = 0
        loadLeftHeaderContent(toView: newView)
        newView.layer.name = "LeftHeaderView"
        newView.leadingAnchor.constraint(equalTo: parentScrollView!.superview!.leadingAnchor, constant: 0).isActive = true
        let right = newView.trailingAnchor.constraint(equalTo: parentScrollView!.leadingAnchor, constant: 0)
        right.priority = .init(rawValue: 500)
        right.isActive = true
        newView.addConstaits([.top:0, .bottom:0])
    }
    
    func loadLeftHeaderContent(toView:UIView) {
        let stack = UIStackView()
        toView.addSubview(stack)
        
        let label:UILabel = .init()
        stack.addArrangedSubview(label)
        
        stack.distribution = .fillProportionally
        stack.spacing = 3
        stack.axis = .horizontal
        label.textAlignment = .center
        label.text = mediaType?.title
        label.font = .type(.smallMedium)
        label.textColor = .init(.greyText)
        stack.addConstaits([.left:2, .right:-2, .bottom:-3])
    }
    
    private func updateLayers() {
        [false, true].forEach {
            drawSeparetors(isVertical: $0)
        }
    }
    
    private func drawSeparetors(isVertical:Bool) {
        let count:CGFloat = isVertical ? (frame.width / 80) : 5
        let midValue = (isVertical ? frame.width : frame.height) / count
        Array(0..<Int(count)).forEach {
            self.layer.drawLine(isVertical ? [
                .init(x: Int(midValue) * $0, y: 0),
                .init(x: Int(midValue) * $0, y: Int(frame.height))
            ] : [
                .init(x: 0, y: Int(midValue) * $0),
                .init(x: Int(frame.width), y: Int(midValue) * $0)
            ], color: .type(.lightSeparetor), width: 0.3, name: isVertical ? "separetorsVerical\($0)" : "separetors\($0)", forceAdd: true)
        }
    }
    
    var parentScrollView:UIScrollView? {
        parentStackView?.superview as? UIScrollView
    }
    
    var parentStackView: UIStackView? {
        superview as? UIStackView
    }
}

extension StackAssetAttachmentView {
    static func create(_ data:[AssetAttachmentProtocol], type:InstuctionAttachmentType, delegate:AssetAttachmentViewDelegate?, to view:UIStackView) {
        let new = StackAssetAttachmentView.init(frame: .zero)
        new.mediaType = type
        new.data = data
        new.tag = type.order
        new.delegate = delegate
        view.addArrangedSubview(new)
    }
}
