/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests to make sure that the `DreamListViewControllerModel` type correctly
                constructs a diff.
*/

import XCTest

class DreamListViewControllerModelDiffTests: XCTestCase {
    func testDiffingEqualModels() {
        let dream1 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])
        let dream2 = Dream(description: "bar", creature: .unicorn(.yellow), effects: [.rain])

        let model1 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            dream1,
            dream2
        ])

        let model2 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            dream1,
            dream2
        ])

        let diff = model1.diffed(with: model2)

        XCTAssertFalse(diff.hasAnyDreamChanges)
        XCTAssertFalse(diff.hasAnyDreamChanges)
        XCTAssertFalse(diff.favoriteCreatureChanged)
        XCTAssertEqual(diff.from, model1)
        XCTAssertEqual(diff.to, model2)
        XCTAssertNil(diff.dreamChange)
    }

    func testDiffRemovingDreamFromModel() {
        let dream1 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])
        let dream2 = Dream(description: "bar", creature: .unicorn(.white), effects: [.laserFocus, .fireflies])
        let dream3 = Dream(description: "baz", creature: .unicorn(.white), effects: [.laserFocus, .fireflies])

        let model1 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            dream1,
            dream2,
            dream3
        ])

        let model2 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            dream1,
            dream2
        ])

        let diff = model1.diffed(with: model2)
        XCTAssertEqual(diff.dreamChange, .removed(dream3))
    }

    func testDiffAppendingDreamFromModel() {
        let dream1 = Dream(description: "foo", creature: .unicorn(.pink), effects: [.fireBreathing])
        let dream2 = Dream(description: "bar", creature: .unicorn(.white), effects: [.laserFocus, .fireflies])
        let dream3 = Dream(description: "baz", creature: .unicorn(.white), effects: [.laserFocus, .fireflies])

        let model1 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            dream1,
            dream2
        ])

        let model2 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            dream1,
            dream2,
            dream3
        ])

        let diff = model1.diffed(with: model2)
        XCTAssertEqual(diff.dreamChange, .inserted(dream3))
    }

    func testDiffFavoriteCreatureChanged() {
        let model1 = DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [])
        let model2 = DreamListViewControllerModel(favoriteCreature: .unicorn(.yellow), dreams: [])

        let diff = model1.diffed(with: model2)
        XCTAssertTrue(diff.favoriteCreatureChanged)
    }
}
