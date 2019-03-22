/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the `Layout` protocol.
*/

import CoreGraphics

/// A type that can layout itself and its contents.
protocol Layout {
    /// Lay out this layout and all of its contained layouts within `rect`.
    mutating func layout(in rect: CGRect)

    /// The type of the leaf content elements in this layout.
    associatedtype Content

    /// Return all of the leaf content elements contained in this layout and its descendants.
    var contents: [Content] { get }
}
