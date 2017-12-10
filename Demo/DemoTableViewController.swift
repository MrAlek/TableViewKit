//
//  DemoTableViewController.swift
//  TableViewKitDemo
//
//  Created by Alek Åström on 2017-12-10.
//  Copyright © 2017 Alek Åström. All rights reserved.
//

import UIKit
import TableViewKit

struct Person {
    var name: String
}

struct Quote {
    let id = UUID().uuidString
    
    var text: String
    var author: Person
}

class DemoTableViewController: UITableViewController {
    
    lazy var dataSource: TableViewDataSource = TableViewDataSource()
    
    var quotes: [Quote] = [
        Quote(text: "I'll be back", author: Person(name: "Arnold Swarzenegger")),
        Quote(text: "Look at me, I'm a pickle!", author: Person(name: "Rick Sanchez")),
        Quote(text: "They may take our lives, but they'll never take our freedom!", author: Person(name: "Mel Gibson")),
        Quote(text: "Wax on, wax off", author: Person(name: "Mr Miyagi")),
        Quote(text: "It's alive! It's alive!", author: Person(name: "Dr Frankenstein")),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        dataSource.setup(with: tableView)
        updateSections(animated: false)
    }
    
    func updateSections(animated: Bool) {
        dataSource.updateSections(to: tableViewSections(), animation: animated ? .automatic : .none)
    }

    func tableViewSections() -> [TableViewSection] {
        return [
            TableViewSection(
                identifier: "section",
                cells: [topLabelCellModel()].flatMap({ $0 }) + quotes.map(cellModel)
            )
        ]
    }
    
    func topLabelCellModel() -> TableViewCellModel? {
        guard let numberOfSelectedQuotes = tableView.indexPathsForSelectedRows?.count, numberOfSelectedQuotes > 0 else { return nil }
        
        return TableViewCellModel(
            cellType: LabelCell.self,
            identifier: "test cell 1",
            data: .init(text: "Quotes selected: \(numberOfSelectedQuotes)"),
            isSelectable: false,
            isMultiSelectable: false
        )
    }
    
    func cellModel(forQuote quote: Quote) -> TableViewCellModel {
        return TableViewCellModel(
            cellType: HandwrittenNoteCell.self,
            identifier: quote.id,
            data: .init(quote: quote),
            selectionHandler: { [weak self] _, _, _ in
                self?.updateSections(animated: true)
            },
            deselectionHandler: { [weak self] _, _, _ in
                self?.updateSections(animated: true)
            },
            copyAction: { _, _, _ in
                UIPasteboard.general.string = quote.shareableString
            }
        )
    }
    
}

extension Quote {
    
    var shareableString: String {
        return "\"\(text)\" – \(author.name)"
    }
    
}

extension HandwrittenNoteCell.Model {
    
    init(quote: Quote) {
        self.title = quote.text
        self.subtitle = "– " + quote.author.name
    }
    
}
