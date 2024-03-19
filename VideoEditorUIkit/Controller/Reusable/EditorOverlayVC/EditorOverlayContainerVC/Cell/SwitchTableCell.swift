//
//  SwitchTableCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 19.03.2024.
//

import UIKit

class SwitchTableCell:UITableViewCell {
    
    @IBOutlet private weak var `switch`: UISwitch!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var data:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.SwitchType?
    
    func set(_ data:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.SwitchType, textColor:UIColor? = nil) {
        if let color = textColor {
            titleLabel.textColor = color
        }
        self.data = data
        `switch`.isOn = data.selected
        titleLabel.text = data.title
        titleLabel.isHidden = data.title.isEmpty
    }
    
    @IBAction func switched(_ sender: UISwitch) {
        data?.didSselect(sender.isOn)
    }
}
