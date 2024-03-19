//
//  UITableView_EditorOverlayContainerVC.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 19.03.2024.
//

import UIKit

extension EditorOverlayContainerVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableData[indexPath.row] {
        case .floatRange(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTableCell", for: indexPath) as! SliderTableCell
            cell.set(data, textColor: parentVC?.textColor)
            return cell
        case .switch(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableCell", for: indexPath) as! SwitchTableCell
            cell.set(data, textColor: parentVC?.textColor)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
