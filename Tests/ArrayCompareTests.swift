//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import XCTest
@testable import TableViewKit

struct TestStruct: Identifiable {
    var identifier: Int
    var text: String
    
    var hashValue: Int { return identifier }
}

func ==(lhs: TestStruct, rhs: TestStruct) -> Bool {
    return (lhs.identifier == rhs.identifier && lhs.text == rhs.text)
}

private struct TestSection: IdentifiableSection {
    var identifier: Int
    var items: [TestStruct]
    
    var hashValue: Int { return identifier }
}

private func ==(lhs: TestSection, rhs: TestSection) -> Bool {
    return lhs.identifier == rhs.identifier // Purposely avoiding to include items in equals
}

class ArrayComparison_Tests: XCTestCase {
    
    func testShouldReturnNoChangesForTwoIdenticalArrays() {
        
        let structs = [
            TestStruct(identifier: 1, text: "1"),
            TestStruct(identifier: 2, text: "2"),
            TestStruct(identifier: 3, text: "3"),
            TestStruct(identifier: 4, text: "4"),
            TestStruct(identifier: 5, text: "5"),
            TestStruct(identifier: 6, text: "6"),
            TestStruct(identifier: 7, text: "7"),
            TestStruct(identifier: 8, text: "8")
        ]
        
        let changes = structs.changes(to: structs)
        XCTAssertEqual(changes.count, 0, "There shouldn't be changes for two identical arrays")
    }
    
    func testShouldReturnExpectedChangingWhenComparingTwoDecentlySizedArrays() {
        
        let noChange = TestStruct(identifier: 5, text: "No Change")
        let delete = TestStruct(identifier: 1, text: "Delete")
        let insert = TestStruct(identifier: 2, text: "Insert")
        let move = TestStruct(identifier: 3, text: "Move")
        let update1 = TestStruct(identifier: 4, text: "Update 1")
        let update2 = TestStruct(identifier: 4, text: "Update 2")
        
        var firstArray = [noChange, delete, move, update1]
        let secondArray = [noChange, move, insert, update2]
        
        
        let expectedChanges = [
            ArrayChange(item: delete, type: .delete(1)),
            ArrayChange(item: insert, type: .insert(2)),
            ArrayChange(item: update2, type: .update(3, 3))
        ]
        
        let changes = firstArray.changes(to: secondArray)
        
        XCTAssertEqual(changes, expectedChanges, "Changes not same as expected!")
        
        firstArray.applyChanges(changes)
        XCTAssertEqual(firstArray, secondArray)
    }
    
    func testTrickyDeleteMoveUpdateCase() {
        
        let x = TestStruct(identifier: 0, text: "X")
        var y = TestStruct(identifier: 1, text: "Y")
        
        var firstArray = [x, y]
        
        y.text = "changed"
        
        let secondArray = [y]
        
        let expectedChanges = [
            ArrayChange(item: x, type: .delete(0)),
            ArrayChange(item: y, type: .update(1, 0))
        ]
        
        let changes = firstArray.changes(to: secondArray)

        XCTAssertEqual(changes, expectedChanges)
        
        firstArray.applyChanges(changes)
        XCTAssertEqual(firstArray, secondArray)
    }
    
    func testWeirdMoveSameIndexCase() {
        let x1 = TestStruct(identifier: 1, text: "")
        let x2 = TestStruct(identifier: 2, text: "")
        let x3 = TestStruct(identifier: 3, text: "")
        
        var firstArray = [x1, x2]
        let secondArray = [x3, x2, x1]
        
        let expectedChanges = [
            ArrayChange(item: x3, type: .insert(0)),
            ArrayChange(item: x2, type: .move(1, 1))
        ]
    
        let changes = firstArray.changes(to: secondArray)
        
        XCTAssertEqual(changes, expectedChanges)
        
        firstArray.applyChanges(changes)
        XCTAssertEqual(firstArray, secondArray)
    }
    
    func testWorstCasePerformance() {
        
        let itemIndexes: [Int] = Array(1...1000)
        
        let beforeItems: [TestStruct] = itemIndexes.map { itemIndex in
            return TestStruct(identifier: itemIndex, text: String(itemIndex))
        }
        
        var afterItems = Array(beforeItems.reversed())
        let extraIndexes: [Int] = Array(1001...2000)
        afterItems += extraIndexes.map { itemIndex in
            return TestStruct(identifier: itemIndex, text: String(itemIndex))
        }
        
        measure {
            let _ = beforeItems.changes(to: afterItems)
        }
    }
    
    func testBestCasePerformance() {
        
        let itemIndexes: [Int] = Array(1...1000)
        
        let beforeItems: [TestStruct] = itemIndexes.map { itemIndex in
            return TestStruct(identifier: itemIndex, text: String(itemIndex))
        }
        
        measure {
            let _ = beforeItems.changes(to: beforeItems)
        }
    }
    
}
