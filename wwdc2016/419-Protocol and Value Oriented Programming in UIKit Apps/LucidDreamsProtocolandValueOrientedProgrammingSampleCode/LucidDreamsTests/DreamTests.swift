/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines test to make sure that the `Dream` type has value semantics.
*/

import XCTest

class DreamValueSemanticsTestCase: XCTestCase {
    func testDreamHasValueSemantics() {
        let dream = Dream(description: "Saw the light", creature: .unicorn(.yellow), effects: [.fireBreathing])

        testValueSemantics(initial: dream, mutations: { (copy: inout Dream) in
            /*
                Change the copy's description to something different than the 
                original dream.
            */
            copy.description = "Saw the light (copy)"
        })
    }
}
