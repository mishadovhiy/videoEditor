//
//  SliderTableCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 19.03.2024.
//

import UIKit

class SliderTableCell: UITableViewCell {
    
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var data:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.FloatType?
    
    func set(_ data:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.FloatType, textColor:UIColor? = nil) {
        if let color = textColor {
            titleLabel.textColor = color
        }
        self.data = data
        slider.value = Float(data.selected ?? 0)
        titleLabel.text = data.title
        titleLabel.isHidden = data.title.isEmpty
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        print(CGFloat(sender.value), " tgrfedws")
        data?.didSelect(CGFloat(sender.value))
    }
}
