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
    var assetChanged:((_ didChange:(_ oldValue: TextAttachmentDB)->TextAttachmentDB)->())?
    
    var getCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        guard let type else {
            return nil
        }
        switch type {
        case .song:
            return []
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
            var newData = oldValue
            newData.textAlighment = new
            return newData
        }
    }
    
    private var textCollectionData:[EditorOverlayVC.OverlayCollectionData]? {
        [
            .init(title: "Text Aligment", image: "textAligment", toOverlay: .init(screenTitle: "Select text Aligment", collectionData: [
                .init(title: "left", didSelect: {
                    self.textAligmentChanged(.left)
                }),
                .init(title: "Center", didSelect: {
                    self.textAligmentChanged(.center)
                }),
                .init(title: "Right", didSelect: {
                    self.textAligmentChanged(.right)
                })
            ])),
            .init(title: "Text Color", image: "colors", toOverlay: .init(screenTitle: "Select text Color", attachmentType: .color(.init(selectedColor: nil, didSelect: { newColor in
                    assetChanged? { oldValue in
                        var value = oldValue
                        value.color = newColor
                        return value
                    }
            })))),
            .init(title: "Border Color", image: "colors", toOverlay: .init(screenTitle: "Select border Color", attachmentType: .color(.init(selectedColor: nil, didSelect: { newColor in
                assetChanged? { oldValue in
                    var value = oldValue
                    value.borderColor = newColor
                    return value
                }
            })))),
            .init(title: "Border Width", image: "size", toOverlay: .init(screenTitle: "Set Border Width", attachmentType: .floatRange(.init(selected: 2, didSelect: { newValue in
                assetChanged? { oldValue in
                    var value = oldValue
                    value.borderWidth = newValue
                    return value
                }
            }))))
        ]
    }
}
