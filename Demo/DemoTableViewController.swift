//
//  DemoTableViewController.swift
//  TableViewKitDemo
//
//  Created by Alek Åström on 2017-12-10.
//  Copyright © 2017 Alek Åström. All rights reserved.
//

import UIKit
import TableViewKit

class DemoTableViewController: UITableViewController {
    
    lazy var dataSource: TableViewDataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TestCell.self)
        dataSource.setup(with: tableView)
        dataSource.updateSections(to: rebuildSections(), animation: .none)
    }

    func rebuildSections() -> [TableViewSection] {
        return [
            TableViewSection(identifier: "section", cells: [
                TableViewCellModel(cellType: TestCell.self, identifier: "test cell 1", data: .init(title: "Testing testing")),
            ])
        ]
    }
    
}

fileprivate class TestCell: UITableViewCell, ReusableViewClass, DataSetupable {
    
    struct Model: Hashable, AnyEquatable {
        let title: String
        
        var hashValue: Int {
            return title.hashValue
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ data: Model) {
        textLabel?.text = data.title
    }
    
}

fileprivate func ==(lhs: TestCell.Model, rhs: TestCell.Model) -> Bool {
    return lhs.title == rhs.title
}
