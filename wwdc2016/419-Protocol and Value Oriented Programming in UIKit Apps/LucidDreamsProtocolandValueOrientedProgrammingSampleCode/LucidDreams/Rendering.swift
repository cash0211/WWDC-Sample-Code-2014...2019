/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Provides the `makeImages(from:completion:)` function that turns dreams
                into images. Note that we're using the `MultiPaneLayout` type to lay
                out the text and images.
*/

import UIKit

/// Makes a single image from a dream.
private func makeImage(from dream: Dream) -> UIImage {
    let size = CGSize(width: 500, height: 200)
    UIGraphicsBeginImageContext(size)

    defer { UIGraphicsEndImageContext() }

    let context = UIGraphicsGetCurrentContext()!

    let content = TextDrawable(text: dream.description, frame: .zero)
    let decoration = ImageDrawable(image: dream.creature.image, frame: .zero)
    let accessories = Array(repeatElement(decoration, count: dream.numberOfCreatures))

    /*
        Here we're re-using one of our layouts to render an image that looks like
        the view layout we have in the app.
    */
    var multiPaneLayout = MultiPaneLayout(content: content, accessories: accessories)
    multiPaneLayout.layout(in: CGRect(origin: .zero, size: size))

    let drawables = multiPaneLayout.contents
    for drawable in drawables {
        drawable.draw(in: context)
    }

    return UIGraphicsGetImageFromCurrentImageContext()!
}

/**
    Creates an array of images from an array of dreams. This is called when the
    user shares dreams in the `DreamListViewController`.
*/
func makeImages(from dreams: [Dream], completion: @escaping ([UIImage]) -> Void) {
    let backgroundQueue = DispatchQueue(label: "com.example.apple-samplecode.LucidDreams.renderer.background")

    backgroundQueue.async {
        let images = dreams.map { makeImage(from: $0) }

        DispatchQueue.main.async {
            completion(images)
        }
    }
}
