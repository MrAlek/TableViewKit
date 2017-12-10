//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import XCTest
@testable import TableViewKit

private struct TestSection: IdentifiableSection {
    let identifier: String
    var items: [TestStruct]
    
    var hashValue: Int {
        return identifier.hashValue
    }
}

private func ==(lhs: TestSection, rhs: TestSection) -> Bool {
    return lhs.identifier == rhs.identifier
}

class SectionedArrayCompareTests: XCTestCase {
    
    func testBasicComparison() {
        let firstData = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 0, text: "Imma be deleted"),
                TestStruct(identifier: 1, text: "Imma be deleted too :(")
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 2, text: "Imma MOVING!")
            ])
        ]
        
        let secondData = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 2, text: "Imma MOVING!")
            ])
        ]
        
        let (sectionChanges, itemChanges) = firstData.changes(toSections: secondData)
        
        let expectedSectionChanges = [ArrayChange(item: firstData[1], type: .delete(1))]
        let expectedItemChanges = [
            SectionedArrayChange(item: firstData[0].items[0], type: .delete(IndexPath(item: 0, section: 0))),
            SectionedArrayChange(item: firstData[0].items[1], type: .delete(IndexPath(item: 1, section: 0))),
            SectionedArrayChange(item: firstData[1].items[0], type: .move(IndexPath(item: 0, section: 1), IndexPath(item: 0, section: 0)))
        ]
        
        XCTAssertEqual(sectionChanges, expectedSectionChanges)
        XCTAssertEqual(itemChanges, expectedItemChanges)
    }
    
    func testSimpleMoveBetweenSections() {
        
        let beforeSections = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 1, text: "Imma still"),
                TestStruct(identifier: 0, text: "IMMA MOVING!")
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 2, text: "Imma also still :)")
            ])
        ]
        
        let afterSections = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 1, text: "Imma still"),
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 2, text: "Imma also still :)"),
                TestStruct(identifier: 0, text: "IMMA MOVING!")
            ])
        ]
        
        let (sectionChanges, itemChanges) = beforeSections.changes(toSections: afterSections)
        
        XCTAssert(sectionChanges.count == 0)
        XCTAssert(itemChanges.count == 1)
        XCTAssertEqual(itemChanges.first, SectionedArrayChange(item: TestStruct(identifier: 0, text: "IMMA MOVING!"), type: .move(IndexPath(item: 1, section: 0), IndexPath(item: 1, section: 1))))
    }
    
    func testComplexMoveUpdateInsertDelete() {
        
        let beforeSections = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 0, text: "delete"),
                TestStruct(identifier: 1, text: "still")
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 2, text: "move")
            ]),
            TestSection(identifier: "z", items: [
                TestStruct(identifier: 3, text: "delete")
            ])
        ]
        
        let afterSections = [
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 10, text: "insert")
            ]),
            TestSection(identifier: "a", items: [
                TestStruct(identifier: 2, text: "move")
            ]),
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 1, text: "still but updating")
            ])
        ]
        
        let (sectionChanges, itemChanges) = beforeSections.changes(toSections: afterSections)
        
        let expectedSectionChanges = [
            ArrayChange(item: beforeSections[2], type: .delete(2)),
            ArrayChange(item: afterSections[1], type: .insert(1)),
            ArrayChange(item: afterSections[0], type: .move(1, 0))
        ]
        
        XCTAssertEqual(sectionChanges, expectedSectionChanges)
        
        let expectedItemChanges = [
            SectionedArrayChange(item: beforeSections[0].items[0], type: .delete(IndexPath(item: 0, section: 0))),
            SectionedArrayChange(item: beforeSections[2].items[0], type: .delete(IndexPath(item: 0, section: 2))),
            SectionedArrayChange(item: afterSections[0].items[0], type: .insert(IndexPath(item: 0, section: 0))),
            SectionedArrayChange(item: afterSections[2].items[0], type: .update(IndexPath(item: 1, section: 0), IndexPath(item: 0, section: 2)))
        ]
        
        XCTAssertEqual(itemChanges, expectedItemChanges)
    }
    
    func testEqualSectionsProducesNoChanges() {
        
        let beforeSections = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 0, text: "a"),
                TestStruct(identifier: 1, text: "s")
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 2, text: "d")
            ]),
            TestSection(identifier: "z", items: [
                TestStruct(identifier: 3, text: "f")
            ])
        ]
        
        let (sectionChanges, itemChanges) = beforeSections.changes(toSections: beforeSections)

        XCTAssert(sectionChanges.count == 0)
        XCTAssert(itemChanges.count == 0)
    }
    
    func testWorstCasePerformanceForComparingManySections() {
        
        let sectionIndexes: [Int] = Array(1...10)
        let itemIndexes: [Int] = Array(1...100)
        
        let beforeSections: [TestSection] = sectionIndexes.map { (sectionIndex: Int) in
            let items: [TestStruct] = itemIndexes.map { itemIndex in
                return TestStruct(identifier: sectionIndex*1000+itemIndex, text: String(itemIndex))
            }
            return TestSection(identifier: String(sectionIndex), items: items)
        }
        
        var afterSections: [TestSection] = Array(beforeSections.reversed())
        afterSections = afterSections.map { section in
            let items: [TestStruct] = Array(section.items.reversed())
            return TestSection(identifier: section.identifier, items: items)
        }
     
        measure {
            let _ = beforeSections.changes(toSections: afterSections)
        }
    }
    
    func testBestCasePerformanceForComparingAverageSections() {
        
        let sectionIndexes: [Int] = Array(1...10)
        let itemIndexes: [Int] = Array(1...100)
        
        let beforeSections: [TestSection] = sectionIndexes.map { (sectionIndex: Int) in
            let items: [TestStruct] = itemIndexes.map { itemIndex in
                return TestStruct(identifier: sectionIndex*1000+itemIndex, text: String(itemIndex))
            }
            return TestSection(identifier: String(sectionIndex), items: items)
        }
        
        measure {
            let _ = beforeSections.changes(toSections: beforeSections)
        }
    }
    
    func testMoveBetweenSectionsAndSimultaneousUpdate() {
        let beforeSections = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 0, text: "a"),
                TestStruct(identifier: 1, text: "s")
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 2, text: "d")
            ])
        ]
        
        let afterSections = [
            TestSection(identifier: "x", items: [
                TestStruct(identifier: 0, text: "a")
            ]),
            TestSection(identifier: "y", items: [
                TestStruct(identifier: 1, text: "THIS ITEM HAS NOW BEEN BOTH MOVED AND UPDATED"),
                TestStruct(identifier: 2, text: "d")
            ])
        ]
        
        let (sectionChanges, itemChanges) = beforeSections.changes(toSections: afterSections)
        
        XCTAssert(sectionChanges.count == 0)
        XCTAssertEqual(Set(itemChanges), [
            SectionedArrayChange(item: afterSections[1].items[0], type: .move(IndexPath(item: 1, section: 0), IndexPath(item: 0, section: 1))),
            SectionedArrayChange(item: afterSections[1].items[0], type: .update(IndexPath(item: 1, section: 0), IndexPath(item: 0, section: 1)))
        ])
    }
    
}
