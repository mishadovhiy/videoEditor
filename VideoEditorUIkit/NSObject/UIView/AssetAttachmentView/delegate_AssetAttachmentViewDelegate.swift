//
//  AssetAttachmentViewDelegate.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 31.12.2023.
//

import UIKit

protocol AssetAttachmentViewDelegate {
    func attachmentSelected(_ data:MovieAttachmentProtocol?)
    var vc:UIViewController { get }
}
