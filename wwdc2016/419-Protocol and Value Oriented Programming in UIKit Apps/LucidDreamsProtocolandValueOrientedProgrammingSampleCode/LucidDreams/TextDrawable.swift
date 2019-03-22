/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains functionality to render an `AttributedString` as a `Drawable`.
*/

import UIKit

/// Draws text.
struct TextDrawable: Layout, Drawable {
    var text: String
    var frame: CGRect

    mutating func layout(in rect: CGRect) {
        frame = rect
    }

    func draw(in context: CGContext) {
        UIGraphicsPushContext(context)
        let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 40)])
        var frame = self.frame
        let height = min(attributedString.size().height, frame.size.height)
        frame.origin.y += 0.5 * frame.size.height - height
        frame.size.height = height
        attributedString.draw(in: frame)
        UIGraphicsPopContext()
    }

    typealias Content = Drawable
    var contents: [Content] {
        return [self]
    }
}
