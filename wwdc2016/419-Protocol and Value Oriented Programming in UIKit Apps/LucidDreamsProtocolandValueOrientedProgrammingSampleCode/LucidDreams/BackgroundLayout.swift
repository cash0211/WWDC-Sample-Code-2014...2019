/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Provides a layout that allows you to put a background behind another
                layout.
*/

import CoreGraphics

/// A layout that diplays its background content behind its foreground content.
struct BackgroundLayout<Background: Layout, Foreground: Layout>: Layout where Background.Content == Foreground.Content {
    typealias Content = Background.Content

    var background: Background
    var foreground: Foreground

    mutating func layout(in rect: CGRect) {
        background.layout(in: rect)
        foreground.layout(in: rect)
    }

    var contents: [Content] {
        return background.contents + foreground.contents
    }
}

/**
    In this extension we define a methods that allow us to easily chain layouts
    together. For example, you can now take any `Layout` type and call
    `withBackground(backgroundLayout)` to get the same layout but with a background. 
    This is a convenient alternative to using initializer syntax if you're composing multiple
    layouts together.
*/
extension Layout {
    /// Returns a layout that shows `self` in front of `background`.
    func withBackground<Background: Layout>(_ background: Background) -> BackgroundLayout<Background, Self> where Background.Content == Content {
        return BackgroundLayout(background: background, foreground: self)
    }
}
