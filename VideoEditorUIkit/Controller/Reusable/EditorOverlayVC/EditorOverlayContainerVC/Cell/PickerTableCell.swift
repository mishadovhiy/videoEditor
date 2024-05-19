//
//  pickerTableCell.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 30.04.2024.
//

import UIKit

class PickerTableCell: UITableViewCell {
    
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var titleLabel: UILabel!
    private var pickerData:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.StringListType?
    private var isLightText:Bool = true
    
    public func set(data:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.StringListType, navigationColor:UIColor) {
        self.pickerData = data
        titleLabel.text = data.title
        self.isLightText = !navigationColor.isLight
        print(isLightText, " tgefrwdqsefrgr ")
        titleLabel.textColor = isLightText ? .white : .black
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        pickerView.selectRow(data.selectedAt, inComponent: 0, animated: false)
    }
    
}

extension PickerTableCell:UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData?.list.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerData?.didSelect(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var label: UILabel

            if let view = view as? UILabel {
                label = view
            } else {
                label = UILabel()
            }

            label.text = pickerData?.list[row] ?? "-"
            label.textAlignment = .center
        label.textColor = isLightText ? .white : .black// UIColor.red
        label.font = .type(.regulatMedium)
            return label
        }
}

