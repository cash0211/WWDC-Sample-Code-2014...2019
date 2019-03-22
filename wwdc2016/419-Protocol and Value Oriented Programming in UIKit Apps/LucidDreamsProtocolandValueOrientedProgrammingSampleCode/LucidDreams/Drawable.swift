/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the `Drawable` protocol.
*/

import CoreGraphics

/// A type that can draw into a context.
protocol Drawable {
    func draw(in context: CGContext)
}
