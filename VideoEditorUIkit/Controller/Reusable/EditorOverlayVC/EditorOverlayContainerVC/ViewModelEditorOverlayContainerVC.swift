//
//  ViewModelEditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 10.03.2024.
//

import Foundation
import UIKit

struct ViewModelEditorOverlayContainerVC {
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
            return [
                .init(title: "Size", toOverlay: .init(screenTitle: "Font size", attachmentType: .floatRange(.init(selected: 0, didSelect: { newValue in
                    assetChanged? { oldValue in
                        var value = oldValue
                        value.fontSize = newValue
                        return value
                    }
                })))),
                .init(title: "Text Aligment", toOverlay: .init(screenTitle: "Font size", attachmentType: .floatRange(.init(selected: 0, didSelect: { newValue in
                    assetChanged? { oldValue in
                        var value = oldValue
                        value.fontSize = newValue
                        return value
                    }
                })))),
                .init(title: "Text Color", toOverlay: .init(screenTitle: "Font size", attachmentType: .color(.init(selectedColor: nil, didSelect: { newColor in
                        assetChanged? { oldValue in
                            var value = oldValue
                            value.color = newColor
                            return value
                        }
                })))),
                .init(title: "Border Color", toOverlay: .init(screenTitle: "Font size", attachmentType: .color(.init(selectedColor: nil, didSelect: { newColor in
                    assetChanged? { oldValue in
                        var value = oldValue
                        value.borderColor = newColor
                        return value
                    }
                })))),
                .init(title: "Border Width", toOverlay: .init(screenTitle: "Font size", attachmentType: .floatRange(.init(selected: 2, didSelect: { newValue in
                    assetChanged? { oldValue in
                        var value = oldValue
                        value.fontSize = newValue
                        return value
                    }
                }))))
            ]
        case .media:
            return []
        }
    }
    
    var colorCollectionData: [EditorOverlayVC.OverlayCollectionData] {
        let colors:[UIColor] = [.red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange, .red, .systemPink, .blue, .orange]
        return colors.compactMap { .init(title: "            ", backgroundColor: $0)}
    }
}
