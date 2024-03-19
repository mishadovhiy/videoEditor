//
//  ViewModelEditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 10.03.2024.
//

import Foundation
import UIKit

struct EditorOverlayContainerVCViewModel {
    var textfieldEditing:Bool = false
    var type:InstuctionAttachmentType?
    var didPress:((PressedType)->())?
    var assetDataHolder:AssetAttachmentProtocol?
    var isEditing:Bool = false
    var getCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        guard let type else {
            return nil
        }
        switch type {
        case .song:
            return songCollectionData
        case .text:
            return textCollectionData
        case .media:
            return imageCollectionData
        }
    }
    
    var colorCollectionData: [EditorOverlayVC.OverlayCollectionData] {
        let colors:[UIColor] = [.red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange]
        return colors.compactMap { .init(title: "            ", backgroundColor: $0)}
    }
    
    private var imageCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        let imageAsset = self.assetDataHolder as? ImageAttachmentDB ?? .init()
        var data:[EditorOverlayVC.OverlayCollectionData] = [
            self.animationCells(current: imageAsset.animations)//,
//            .init(title: "Border radius", toOverlay: .init(screenTitle: "Border radius", attachmentType: .floatRange(.init(selected: imageAsset?.borderRadius ?? 0, didSelect: { newValue in
//                self.didPress?(.assetChanged({ oldValue in
//                    var value = oldValue as? ImageAttachmentDB ?? .init()
//                    value.borderRadius = newValue
//                    return value
//                }))
//            }))))
        ]
        if isEditing {
            data.append(trashCell)
            data.insert(.init(title: "Change", image: "addImage", didSelect: {
                self.didPress?(.upload(.photoLibrary))
            }), at: 0)
        } else {
            data.insert(.init(title: "Choose Image", image: "addImage", didSelect: {
                self.didPress?(.upload(.photoLibrary))
            }), at: 0)
        }
        return data
    }
    
    private var songCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        var data:[EditorOverlayVC.OverlayCollectionData] = []
        let songData = assetDataHolder as? SongAttachmentDB
        if songData?.attachmentURL ?? "" == "" && !(songData?.selfMovie ?? true) {
            data.append(.init(title: "Apple Music", didSelect: {
                self.didPress?(.upload(.appleMusic))
            }))
            data.append(.init(title: "Files", didSelect: {
                self.didPress?(.upload(.files))
            }))
        } else {
            if !(songData?.selfMovie ?? true) {
                data.append(.init(title: "Change Sound", image: "addSound", didSelect: {
                    self.didPress?(.assetChanged({
                        var new = $0 as? SongAttachmentDB ?? .init()
                        new.attachmentURL = ""
                        return new
                    }))
                    self.didPress?(.reload)
                    
                }))
            }
            data.append(.init(title: "Volume", image: "valuem", toOverlay: .init(screenTitle: "Set sound volume", attachmentType: .floatRange(.init(selected: (assetDataHolder as? SongAttachmentDB)?.volume ?? 0, didSelect: { newValue in
                self.didPress?(.assetChanged({
                    var new = $0 as? SongAttachmentDB ?? .init()
                    new.volume = newValue
                    return new
                }))
            })))))
        }
        return data
    }
    
    private var textCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        let textData = assetDataHolder as? TextAttachmentDB ?? .init()
        var data: [EditorOverlayVC.OverlayCollectionData] = [
            .init(title: "Text Aligment", image: "textAligment", toOverlay: .init(screenTitle: "Select text Aligment", collectionData: [
                .init(title: "left", image: "textLeft", didSelect: {
                    self.textAligmentChanged(.left)
                }),
                .init(title: "Center", image: "textCenter", didSelect: {
                    self.textAligmentChanged(.center)
                }),
                .init(title: "Right", image: "textRight", didSelect: {
                    self.textAligmentChanged(.right)
                })
            ])),
            .init(title: "Text Color", image: "colors", toOverlay: .init(screenTitle: "Select text Color", attachmentType: .color(.init(selectedColor: assetDataHolder?.color, didSelect: { newColor in
                self.didPress?(.assetChanged({ oldValue in
                    var value = oldValue as? TextAttachmentDB ?? .init()
                    value.color = newColor
                    return value
                }))
            })))),
            animationCells(current: textData.animations)
            //,
//            .init(title: "Border Color", image: "colors", toOverlay: .init(screenTitle: "Select border Color", attachmentType: .color(.init(selectedColor: (assetDataHolder as? TextAttachmentDB)?.borderColor, didSelect: { newColor in
//                self.didPress?(.assetChanged({ oldValue in
//                    var value = oldValue as? TextAttachmentDB ?? .init()
//                    value.borderColor = newColor
//                    return value
//                }))
//            })))),
//            .init(title: "Border Width", image: "size", toOverlay: .init(screenTitle: "Set Border Width", attachmentType: .floatRange(.init(selected: (assetDataHolder as? TextAttachmentDB)?.borderWidth, didSelect: { newValue in
//                self.didPress?(.assetChanged({ oldValue in
//                    var value = oldValue as? TextAttachmentDB ?? .init()
//                    value.borderWidth = newValue
//                    return value
//                }))
//            }))))
            
        ]
        if isEditing {
            data.append(trashCell)
        }
        return data
    }
}

extension EditorOverlayContainerVCViewModel {
    enum UploadPressedType {
        case appleMusic
        case files
        case photoLibrary
    }
    
    enum PressedType {
        case delete
        case reload
        case assetChanged ((_ oldValue: AssetAttachmentProtocol)->AssetAttachmentProtocol)
        case upload (_ type:UploadPressedType)
    }
}

fileprivate extension EditorOverlayContainerVCViewModel {
    private func textAligmentChanged(_ new:NSTextAlignment) {
        didPress?(.assetChanged({
            var newData = $0 as? TextAttachmentDB ?? .init()
            newData.textAlighment = new
            return newData
        }))
    }
    
    private var trashCell:EditorOverlayVC.OverlayCollectionData {
        return .init(title: "Delete", image: "trash") {
            self.didPress?(.delete)
        }
    }
    

    private func animationCells(current:DB.DataBase.MovieParametersDB.AnimationMovieAttachment) -> EditorOverlayVC.OverlayCollectionData {
        let data: [EditorOverlayVC.ToOverlayData.AttachmentOverlayType] = [
            .switch(.init(title: "Repeated scale", selected: current.needScale, didSselect: { newValue in
                self.didPress?(.assetChanged({oldValue in
                    var new = oldValue as? MovieAttachmentProtocol ?? TextAttachmentDB.demo
                    new.animations.needScale = newValue
                    return new
                }))
            }))
        ]
//        if current.needScale {
//            data.append(.floatRange(.init(title: "Scale range", selected: current.scaleDuration, didSelect: { newValue in
//                self.didPress?(.assetChanged({oldValue in
//                    var new = oldValue as? MovieAttachmentProtocol ?? TextAttachmentDB.demo
//                    new.animations.scaleDuration = newValue
//                    return new
//                }))
//            })))
//        }
        return .init(title: "Animation", image: "animation", toOverlay: .init(screenTitle: "Set animation", tableData: data))
    }
}
