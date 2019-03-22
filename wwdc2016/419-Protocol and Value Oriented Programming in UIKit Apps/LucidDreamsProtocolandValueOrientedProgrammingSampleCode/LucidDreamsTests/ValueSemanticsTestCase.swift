/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Provides a generic implementation of testing a value for value semantics.
*/

import XCTest

/**
    A generic implementation that allows you to test whether or not your value
    has value semantics.
*/
func testValueSemantics<Value: Equatable>(initial: Value, mutations: (inout Value) -> Void) {
    var copy = initial
    XCTAssertEqual(initial, copy)

    mutations(&copy)
    XCTAssertNotEqual(initial, copy)
}
