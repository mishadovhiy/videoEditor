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
    
    public func set(data:EditorOverlayVC.ToOverlayData.AttachmentOverlayType.StringListType) {
        self.pickerData = data
        titleLabel.text = data.title
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString.init(string: pickerData?.list[row] ?? "-", attributes: [
            .font:UIFont.systemFont(ofSize: 8)
        ])
    }
}

