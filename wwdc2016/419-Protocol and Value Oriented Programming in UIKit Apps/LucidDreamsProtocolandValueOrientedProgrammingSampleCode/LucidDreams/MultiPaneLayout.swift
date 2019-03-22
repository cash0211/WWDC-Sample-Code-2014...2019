/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a `MultiPaneLayout` that allows you to get a similar effect
                as the `DecoratingLayout` except that the accessory views are laid
                out in a cascade.
*/

import CoreGraphics

/**
    A layout that looks similar to a `DecoratingLayout` except that its decoration
    layout is composed of accessory layouts in a cascading layout.
*/
struct MultiPaneLayout<ChildContent: Layout, Accessory: Layout>: Layout where ChildContent.Content == Accessory.Content {
    typealias Content = ChildContent.Content

    /*
        Note that we're using **composition** here to combine smaller values together
        with other values to create a more complicated layout.
    */
    private var composedLayout: DecoratingLayout<ChildContent, CascadingLayout<Accessory>>

    init(content: ChildContent, accessories: [Accessory]) {
        // Here we're composing the `CascadingLayout` with the `DecoratingLayout`.
        let decoration = CascadingLayout(children: accessories)
        composedLayout = DecoratingLayout(content: content, decoration: decoration)
    }

    mutating func layout(in rect: CGRect) {
        composedLayout.layout(in: rect)
    }

    var contents: [Content] {
        return composedLayout.contents
    }
}
