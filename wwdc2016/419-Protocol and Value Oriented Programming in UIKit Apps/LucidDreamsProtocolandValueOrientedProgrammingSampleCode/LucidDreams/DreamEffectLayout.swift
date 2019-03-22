/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a layout that's used to lay out the `Dream` that's shown in
                the detail view.
*/

import CoreGraphics

/** 
    The layout used for the `Dream` preview functionality in `DreamPreviewHeaderReusableView`.
    This type composes multiple smaller layouts together to form its layout.
*/
struct DreamEffectLayout<ChildContent: Layout, Decoration: Layout, Effect: Layout>: Layout where
ChildContent.Content == Decoration.Content, ChildContent.Content == Effect.Content {
    typealias Content = ChildContent.Content

    private var content: ChildContent
    private var decoration: Decoration
    private var effects: [Effect]

    init(content: ChildContent, decoration: Decoration, effects: [Effect]) {
        self.content = content
        self.decoration = decoration
        self.effects = effects
    }

    mutating func layout(in rect: CGRect) {
        // Here we're composing many different layouts to achieve the desired layout.
        let stack = ZStackLayout(children: effects)

        /*
            Note the simple way to create a `BackgroundLayout` using the 
            `withBackground(...)` method.
        */
        let combinedDecoration = stack.withBackground(decoration)

        var decoratingLayout = DecoratingLayout(content: content, decoration: combinedDecoration)
        decoratingLayout.layout(in: rect)
    }

    var contents: [Content] {
        return content.contents + decoration.contents + effects.flatMap { $0.contents }
    }
}
