//
//  CaishenTests.swift
//  CaishenTests
//
//  Created by Harlan Kellaway on 4/20/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import XCTest
@testable import Caishen

class CaishenTests: XCTestCase {

    func testStringSplitting() {
        let someString = "1234"
        let length2 = DetailInputTextField.split(someString, expectedInputLength: 2)
        XCTAssert(length2.currentText == "12")
        XCTAssert(length2.overflowText == "34")
        let length3 = DetailInputTextField.split(someString, expectedInputLength: 3)
        XCTAssert(length3.currentText == "123")
        XCTAssert(length3.overflowText == "4")
    }
}
