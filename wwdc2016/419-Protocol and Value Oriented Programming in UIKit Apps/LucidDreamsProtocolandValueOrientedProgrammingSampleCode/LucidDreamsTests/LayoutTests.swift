/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines tests to ensure that some of our layouts are working as expected.
*/

import XCTest

/**
    A simple layout type to use for testing. We can check the frame after laying
    out the rect to see the effect of composing other layouts. Note that this layout's
    `Content` is also a `TestLayout`, so these layouts will be at the leaves.
*/
struct TestLayout: Layout {
    typealias Content = TestLayout

    var frame: CGRect

    init(frame: CGRect = .zero) {
        self.frame = frame
    }

    mutating func layout(in rect: CGRect) {
        self.frame = rect
    }

    var contents: [Content] {
        return [self]
    }
}

class LayoutTests: XCTestCase {
    func testLayout() {
        let child1 = TestLayout()
        let child2 = TestLayout()

        var layout = DecoratingLayout(content: child1, decoration: child2)
        layout.layout(in: CGRect(x: 0, y: 0, width: 90, height: 40))

        // Check to see that the frames are at the expected values.
        XCTAssertEqual(layout.contents[0].frame, CGRect(x: 0, y: 5, width: 25, height: 30))
        XCTAssertEqual(layout.contents[1].frame, CGRect(x: 35, y: 5, width: 50, height: 30))
    }
}
