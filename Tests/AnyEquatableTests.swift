//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import XCTest
@testable import TableViewKit

class AnyEquatableTests: XCTestCase {
    
    let testString1: AnyEquatable = "test1"
    let testString2: AnyEquatable = "test2"
    let testOptionalString: AnyEquatable? = "testOptional"
    let testBool: AnyEquatable = true
    let testOptionalBool: AnyEquatable? = true
    
    func testSameTypeEquality() {
        XCTAssertTrue(testString1 == testString1)
        XCTAssertTrue(testString1 == "test1")
        
        XCTAssertFalse(testString1 == testString2)
        XCTAssertFalse(testString1 == "test2")
        
        XCTAssertTrue(testBool == testBool)
        XCTAssertTrue(testBool == true)
        XCTAssertFalse(testBool == false)
    }
    
    func testOptionalEquality() {
        XCTAssertTrue(testOptionalString == testOptionalString)
        XCTAssertTrue(testOptionalString == "testOptional")
        XCTAssertFalse(testOptionalString == nil)
        XCTAssertTrue(testOptionalBool == testBool)
        XCTAssertFalse(testOptionalBool == false)
        XCTAssertFalse(testOptionalBool == nil)
    }
    
    func testNilEquality() {
        let testNil: AnyEquatable? = nil
        XCTAssertTrue(testNil == nil)
        XCTAssertFalse(testNil == "test")
    }
    
    func testDifferentTypesFail() {
        XCTAssertFalse(testString1 == testBool)
    }
    
}
