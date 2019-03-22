/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a `CascadingLayout` that allows you to lay out content diagonally.
*/

import CoreGraphics

/// A layout that diagonally lays out its children.
struct CascadingLayout<Child: Layout>: Layout {
    typealias Content = Child.Content

    var children: [Child]
    var overlapFactor: CGFloat

    init(children: [Child], overlapFactor: CGFloat = 0.2) {
        self.children = children
        self.overlapFactor = overlapFactor
    }

    mutating func layout(in rect: CGRect) {
        let childSizeFactor = 1.0 / (1.0 + overlapFactor * CGFloat(children.count - 1))
        var childRect = rect
        childRect.size.width *= childSizeFactor
        childRect.size.height *= childSizeFactor
        for index in children.indices {
            children[index].layout(in: childRect)
            childRect.origin.x += childRect.size.width * overlapFactor
            childRect.origin.y += childRect.size.height * overlapFactor
        }
    }

    var contents: [Content] {
        return children.flatMap { $0.contents }
    }
}
