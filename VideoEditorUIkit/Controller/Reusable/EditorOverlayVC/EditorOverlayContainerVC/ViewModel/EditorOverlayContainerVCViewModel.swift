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
    var isEditing:Bool {
        return (assetDataHolder as? ImageAttachmentDB)?.image?.isEmpty ?? false == false
    }
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
        let colors:[Constants.Color] = [.clear, .red2, .orange, .yellow, .green, .greenBlue, .blue, .darkBlue, .purpure, .pink3, .pink2, .pinkPurpure, .black, .greyText, .greyText6, .white]
        return colors.compactMap { .init(title: "            ", backgroundColor: .type($0))}
    }
    
    private var imageCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        let imageAsset = self.assetDataHolder as? ImageAttachmentDB ?? .init()
        var data:[EditorOverlayVC.OverlayCollectionData] = []
        layerSetupCells().forEach {
            data.append($0)
        }
        if isEditing {
            data.insert(trashCell, at: 0)
            data.insert(trashCell(removeImage: true), at: 1)
        } else {
            data.insert(.init(title: "Galary\nChoose Image", didSelect: {
                self.didPress?(.upload(.photoLibrary))
            }), at: 0)
            data.insert(.init(title: "Document\nChoose Image", didSelect: {
                self.didPress?(.upload(.filePhotots))
            }), at: 1)
        }
        data.append(self.animationCells(current: imageAsset.animations))
        return data
    }
    
    private var songCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        var data:[EditorOverlayVC.OverlayCollectionData] = []
        let songData = assetDataHolder as? SongAttachmentDB
        if songData?.attachmentURL ?? "" == "" && !(songData?.selfMovie ?? true) {
//            data.append(.init(title: "Apple Music", didSelect: {
//                self.didPress?(.upload(.appleMusic))
//            }))
            data.append(.init(title: "Files", didSelect: {
                self.didPress?(.upload(.files))
            }))
        } else if !(songData?.selfMovie ?? true) {
            data.insert(trashCell, at: 0)
        } else if songData?.selfMovie ?? false {
            data.append(.init(title: "Volume", toOverlay: .init(screenTitle: "General Movie Volume", attachmentType: .floatRange(.init(selected: songData?.volume, didSelect: { newValue in
                didPress?(.assetChanged({ oldValue in
                    var new = oldValue as? SongAttachmentDB
                    new?.volume = newValue
                    return new ?? songData!
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
            
        ]
        layerSetupCells(isText: true).forEach {
            data.append($0)
        }
        data.append(animationCells(current: textData.animations))
        if isEditing {
            data.insert(trashCell, at: 0)
        }
        return data
    }
}

extension EditorOverlayContainerVCViewModel {
    enum UploadPressedType {
        case appleMusic
        case files
        case photoLibrary
        case filePhotots
        case audioFile
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
        return trashCell()
    }
    
    private func trashCell(removeImage:Bool = false) -> EditorOverlayVC.OverlayCollectionData {
        return .init(title: removeImage ? "Remove Image" : "Delete", image: "trash", didSelect:{
            if removeImage {
                self.didPress?(.assetChanged({ oldValue in
                    var new = oldValue as? ImageAttachmentDB
                    if new == nil {
                        new = .init()
                    }
                    new?.image = nil
                    return new!
                }))
                self.didPress?(.reload)
            } else {
                self.didPress?(.delete)
            }
        })
    }
    
    private func layerColorCells(isText: Bool = false) ->  EditorOverlayVC.OverlayCollectionData {
        let asset = self.assetDataHolder as? MovieAttachmentProtocol
        var cells:[EditorOverlayVC.OverlayCollectionData] = [
            .init(title: "Background color", image: "colors", toOverlay: .init(screenTitle: "Background color", attachmentType: .color(.init(title: "Background color", selectedColor: asset?.backgroundColor, didSelect: { newColor in
                self.didPress?(.assetChanged({ oldValue in
                    var new = oldValue as? MovieAttachmentProtocol
                    new?.backgroundColor = newColor
                    return new ?? asset!
                }))
            }))))
        ]
        if isText {
            cells.append(.init(title: "Text Color", image: "colors", toOverlay: .init(screenTitle: "Select text Color", attachmentType: .color(.init(selectedColor: assetDataHolder?.color, didSelect: { newColor in
                self.didPress?(.assetChanged({ oldValue in
                    var value = oldValue as? TextAttachmentDB ?? .init()
                    value.color = newColor
                    return value
                }))
            })))))
        }
        if cells.count == 1 {
            return cells.first!
        } else {
            return .init(title: "Colors", image: "colors", toOverlay: .init(screenTitle: "Colors", collectionData: cells))
        }
    }
    
    private func layerSetupCells(isText:Bool = false) -> [EditorOverlayVC.OverlayCollectionData] {
        let asset = self.assetDataHolder as? MovieAttachmentProtocol
        return [
            layerColorCells(isText: isText),
            .init(title: "Layer", image: "shadow", toOverlay: .init(screenTitle: "Layer", collectionData: [
                borderCells(asset),
                shadowCells(asset),
                .init(title: "Opacity", image: "opacity", toOverlay: .init(screenTitle: "Opacity", tableData: [
                    .floatRange(.init(selected: asset?.opacity, didSelect: { newValue in
                        self.didPress?(.assetChanged({
                            var new = $0 as? MovieAttachmentProtocol
                            new?.opacity = newValue
                            return new ?? asset!
                        }))
                    }))
                ]))
            ]))
        ]
    }
    
    private func shadowCells(_ asset:MovieAttachmentProtocol?) -> EditorOverlayVC.OverlayCollectionData {
        .init(title: "Shadow", image: "shadow", toOverlay: .init(screenTitle: "Shadow", collectionData: [
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
        .init(title: "Border", image: "border", toOverlay: .init(screenTitle: "Border", collectionData: [
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
        var repeatedTypes = AppeareAnimationType.repeatedTypes.compactMap({
            $0.title
        })
        repeatedTypes.append("None")
        print(current.appeareAnimation.duration, " thefrdw")
        let data: [EditorOverlayVC.ToOverlayData.AttachmentOverlayType] = [
            .segmented(.init(title: "Appeare\nAnimation", list: AppeareAnimationType.allCases.compactMap({
                $0.title
            }), selectedAt: current.appeareAnimation.key.rawValue, didSelect: { at in
                self.didPress?(.assetChanged({oldValue in
                    var new = oldValue as? MovieAttachmentProtocol ?? TextAttachmentDB.demo
                    new.animations.appeareAnimation.key = .init(rawValue: at) ?? .opacity
                    return new
                }))
            })),
            .floatRange(.init(title: "Appeare\nDuration", selected: current.appeareAnimation.duration, didSelect: { newValue in
                self.didPress?(.assetChanged({oldValue in
                    var new = oldValue as? MovieAttachmentProtocol ?? TextAttachmentDB.demo
                    new.animations.appeareAnimation.duration = newValue
                    return new
                }))
            })),
            .segmented(.init(title: "Repeated\nAnimation", list: repeatedTypes, selectedAt: current.repeatedAnimations?.key.rawValue ?? (repeatedTypes.count - 1), didSelect: { at in
                self.didPress?(.assetChanged({oldValue in
                    var new = oldValue as? MovieAttachmentProtocol ?? TextAttachmentDB.demo
                    if new.animations.repeatedAnimations == nil {
                        new.animations.repeatedAnimations = .init()
                    }
                    if let newValue = AppeareAnimationType.init(rawValue: at),
                       AppeareAnimationType.repeatedTypes.contains(newValue)
                    {
                        new.animations.repeatedAnimations?.key = newValue
                        print(newValue, " yhgerfwds")
                    } else {
                        new.animations.repeatedAnimations = nil
                    }
                    return new
                }))
            }))
        ]
        return .init(title: "Animation", image: "animation", toOverlay: .init(screenTitle: "Set animation", screenHeight: .big, tableData: data))
    }
}
