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
            self.animationCells(current: imageAsset.animations)
        ]
        layerSetupCells().forEach {
            data.append($0)
        }
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
        } else if !(songData?.selfMovie ?? true) {
            data.append(trashCell)
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
        ]
        layerSetupCells().forEach {
            data.append($0)
        }
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
    
    private func layerSetupCells() -> [EditorOverlayVC.OverlayCollectionData] {
        let asset = self.assetDataHolder as? MovieAttachmentProtocol
        return [
            borderCells(asset),
            shadowCells(asset),
            .init(title: "Background color", image: "colors", toOverlay: .init(screenTitle: "Background color", attachmentType: .color(.init(title: "Background color", selectedColor: asset?.backgroundColor, didSelect: { newColor in
                self.didPress?(.assetChanged({ oldValue in
                    var new = oldValue as? MovieAttachmentProtocol
                    new?.backgroundColor = newColor
                    return new ?? asset!
                }))
            })))),
            .init(title: "Opacity", toOverlay: .init(screenTitle: "Opacity", tableData: [
                .floatRange(.init(selected: asset?.opacity, didSelect: { newValue in
                    self.didPress?(.assetChanged({
                        var new = $0 as? MovieAttachmentProtocol
                        new?.opacity = newValue
                        return new ?? asset!
                    }))
                }))
            ]))
        ]
    }
    
    private func shadowCells(_ asset:MovieAttachmentProtocol?) -> EditorOverlayVC.OverlayCollectionData {
        .init(title: "Shadow", toOverlay: .init(screenTitle: "Shadow", collectionData: [
            .init(title: "Shadow Size", image: "size", toOverlay: .init(screenTitle: "Shadow size", screenHeight: .big, tableData: [
                .floatRange(.init(title: "Shadow Radius", selected: asset?.shadows.radius, didSelect: { newValue in
                    self.didPress?(.assetChanged({
                        var new = $0 as? MovieAttachmentProtocol
                        new?.shadows.radius = newValue
                        return new ?? asset!
                    }))
                })),
                .floatRange(.init(title: "Shadow Opacity", selected: asset?.shadows.opasity, didSelect: { newValue in
                    self.didPress?(.assetChanged({
                        var new = $0 as? MovieAttachmentProtocol
                        new?.shadows.opasity = newValue
                        return new ?? asset!
                    }))
                }))
            ])),
            .init(title: "Color", image: "colors", toOverlay: .init(screenTitle: "Shadow color", attachmentType: .color(.init(title: "Set shadow color", selectedColor: asset?.shadows.color, didSelect: { newColor in
                self.didPress?(.assetChanged({
                    var new = $0 as? MovieAttachmentProtocol
                    new?.shadows.color = newColor
                    return new ?? asset!
                }))
            }))))
        ]))
    }
    
    private func borderCells(_ asset:MovieAttachmentProtocol?) -> EditorOverlayVC.OverlayCollectionData {
        .init(title: "Border", image: "size", toOverlay: .init(screenTitle: "Border", collectionData: [
            .init(title: "Border Size", image: "size", toOverlay: .init(screenTitle: "Border frames", screenHeight: .big, tableData: [
                .floatRange(.init(title: "Border Width", selected: asset?.borderWidth, didSelect: { newValue in
                    self.didPress?(.assetChanged({
                        var new = $0 as? MovieAttachmentProtocol
                        new?.borderWidth = newValue
                        return new ?? asset!
                    }))
                })),
                .floatRange(.init(title: "Border Radius", selected: asset?.borderRadius, didSelect: { newValue in
                    self.didPress?(.assetChanged({
                        var new = $0 as? MovieAttachmentProtocol
                        new?.borderRadius = newValue
                        return new ?? asset!
                    }))
                }))
            ])),
            .init(title: "Color", image: "colors", toOverlay: .init(screenTitle: "Border color", attachmentType: .color(.init(title: "Set border color", selectedColor: asset?.borderColor, didSelect: { newColor in
                self.didPress?(.assetChanged({
                    var new = $0 as? MovieAttachmentProtocol
                    new?.borderColor = newColor
                    return new ?? asset!
                }))
            }))))
        ]))
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
