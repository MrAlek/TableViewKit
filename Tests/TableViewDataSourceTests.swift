//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import XCTest
@testable import TableViewKit

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
    
    func setup(_ model: Model) {
        textLabel?.text = model.title
    }
    
}

fileprivate func ==(lhs: TestCell.Model, rhs: TestCell.Model) -> Bool {
    return lhs.title == rhs.title
}

class TableViewDataSourceTests: XCTestCase {
    
    let dataSource =  TableViewDataSource(sections: [
        TableViewSection(identifier: "Test Section", cells: [
            TableViewCellModel(cellType: TestCell.self, identifier: "test cell 1", model: .init(title: "Testing testing")),
            TableViewCellModel(cellType: TestCell.self, identifier: "test cell 2", model: .init(title: "Boom"))
        ])
    ])
    
    func testFindsIndexPathForIdentifier() {
        XCTAssertEqual(dataSource.indexPathForRow(identifiedBy: "test cell 2"), IndexPath(row: 1, section: 0))
    }
    
    func testDoesNotMistakeSectionIdentifierForCellIdentifier() {
        XCTAssertNil(dataSource.indexPathForRow(identifiedBy: "Test Section"))
    }
    
    func testReturnsNilForFindingIndexPathOfCellWithIdentifierNotInDataSource() {
        XCTAssertNil(dataSource.indexPathForRow(identifiedBy: "THIS IDENTIFIER IS NOWHERE"))
    }

}
