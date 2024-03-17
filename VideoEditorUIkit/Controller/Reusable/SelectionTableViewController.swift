//
//  SelectionTableViewController.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 14.03.2024.
//

import UIKit

class SelectionTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var tableData:[TableData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    struct TableData {
        var value:String
        var didSelect:(()->())?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension SelectionTableViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionTableCell", for: indexPath) as! SelectionTableCell
        cell.mainLabel.text = tableData[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableData[indexPath.row].didSelect?()
    }
}

class SelectionTableCell:UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
}

extension SelectionTableViewController {
    static func configure() -> SelectionTableViewController {
        let vc = UIStoryboard(name: "SelectionTable", bundle: nil).instantiateViewController(withIdentifier: "SelectionTableViewController") as? SelectionTableViewController ?? .init()
        return vc
    }
}
