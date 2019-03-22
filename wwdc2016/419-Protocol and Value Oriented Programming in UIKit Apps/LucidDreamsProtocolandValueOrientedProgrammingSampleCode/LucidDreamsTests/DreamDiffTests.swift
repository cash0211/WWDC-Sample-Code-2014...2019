/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests to make sure that the `Dream` type correctly constructs a diff.
*/

import XCTest

class DreamDiffTests: XCTestCase {
    func testDiffingEqualDreams() {
        let dream1 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])
        let dream2 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])

        let diff = dream1.diffed(with: dream2)

        XCTAssertNil(diff.creatureChange)
        XCTAssertTrue(diff.insertedEffects.isEmpty)
        XCTAssertTrue(diff.removedEffects.isEmpty)
        XCTAssertNil(diff.descriptionChange)
        XCTAssertFalse(diff.hasChanges)
    }

    func testDiffsAreEqual() {
        let dream1 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])
        let dream2 = Dream(description: "bar", creature: .unicorn(.white), effects: [.laserFocus, .fireflies])

        let diff = dream1.diffed(with: dream2)

        XCTAssertEqual(diff,  diff)
    }

    func testDiffingDifferentDreams() {
        let dream1 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])
        let dream2 = Dream(description: "bar", creature: .unicorn(.white), effects: [.laserFocus, .fireflies])

        let diff = dream1.diffed(with: dream2)

        XCTAssertEqual(diff.descriptionChange?.from, "foo")
        XCTAssertEqual(diff.descriptionChange?.to, "bar")

        XCTAssertEqual(diff.creatureChange?.from, .unicorn(.pink))
        XCTAssertEqual(diff.creatureChange?.to, .unicorn(.white))

        XCTAssertEqual(diff.removedEffects, [.fireBreathing])
        XCTAssertEqual(diff.insertedEffects, [.laserFocus, .fireflies])

        XCTAssertTrue(diff.hasChanges)
    }
}
