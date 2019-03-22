/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains functionality to render a `UIImage` as a `Drawable`.
*/

import UIKit

/// Draws an image.
struct ImageDrawable: Layout, Drawable {
    var image: UIImage
    var frame: CGRect

    mutating func layout(in rect: CGRect) {
        frame = rect
    }

    func draw(in context: CGContext) {
        UIGraphicsPushContext(context)
        image.draw(in: frame)
        UIGraphicsPopContext()
    }
    
    typealias Content = Drawable
    var contents: [Content] {
        return [self]
    }
}
