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
    var assetChanged:((_ didChange:(_ oldValue: AssetAttachmentProtocol)->AssetAttachmentProtocol)->())?
    var assetDataHolder:AssetAttachmentProtocol?
    var uploadPressed:((_ type:UploadPressedType)->())?
    enum UploadPressedType {
        case appleMusic
        case files
        case photoLibrary
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
            return []
        }
    }
    
    var colorCollectionData: [EditorOverlayVC.OverlayCollectionData] {
        let colors:[UIColor] = [.red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange]
        return colors.compactMap { .init(title: "            ", backgroundColor: $0)}
    }
    
    private func textAligmentChanged(_ new:NSTextAlignment) {
        assetChanged? {oldValue in
            var newData = oldValue as? TextAttachmentDB ?? .init()
            newData.textAlighment = new
            return newData
        }
    }
    
    private var songCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        var data:[EditorOverlayVC.OverlayCollectionData] = []
        let songData = assetDataHolder as? SongAttachmentDB
        if songData?.attachmentURL ?? "" == "" && !(songData?.selfMovie ?? true) {
            data.append(.init(title: "Apple Music", didSelect: {
                self.uploadPressed?(.appleMusic)
            }))
            data.append(.init(title: "Files", didSelect: {
                self.uploadPressed?(.files)
            }))
        } else {
            if !(songData?.selfMovie ?? true) {
                data.append(.init(title: "Change Sound", didSelect: {
                    assetChanged?({
                        var new = $0 as? SongAttachmentDB ?? .init()
                        new.attachmentURL = ""
                        return new
                    })
                }))
            }
            data.append(.init(title: "Volume", toOverlay: .init(screenTitle: "Set sound volume", attachmentType: .floatRange(.init(selected: (assetDataHolder as? SongAttachmentDB)?.volume ?? 0, didSelect: { newValue in
                self.assetChanged?({oldValue in
                    var new = oldValue as? SongAttachmentDB ?? .init()
                    new.volume = newValue
                    return new
                })
            })))))
        }
        return data
    }
    
    private var textCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        [
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
                    assetChanged? { oldValue in
                        var value = oldValue as? TextAttachmentDB ?? .init()
                        value.color = newColor
                        return value
                    }
            })))),
            .init(title: "Border Color", image: "colors", toOverlay: .init(screenTitle: "Select border Color", attachmentType: .color(.init(selectedColor: (assetDataHolder as? TextAttachmentDB)?.borderColor, didSelect: { newColor in
                assetChanged? { oldValue in
                    var value = oldValue as? TextAttachmentDB ?? .init()
                    value.borderColor = newColor
                    return value
                }
            })))),
            .init(title: "Border Width", image: "size", toOverlay: .init(screenTitle: "Set Border Width", attachmentType: .floatRange(.init(selected: (assetDataHolder as? TextAttachmentDB)?.borderWidth, didSelect: { newValue in
                assetChanged? { oldValue in
                    var value = oldValue as? TextAttachmentDB ?? .init()
                    value.borderWidth = newValue
                    return value
                }
            })))),
            .init(title: "Delete Text", didSelect: {
                
            })
        ]
    }
}
