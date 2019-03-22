/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a header view for the collection view used in `DreamDetailViewController`
                to display a preview of the dream. This view uses an `SKScene` subclass
                called `DreamScene` to display its content, but `DreamScene` instance
                is using a `DreamEffectLayout` under the hood to layout its content.
*/

import UIKit
import SpriteKit

/// A collection view reusable view that displays a full preview for a `Dream`.
class DreamPreviewHeaderReusableView: UICollectionReusableView {
    // MARK: Properties
    
    static let reuseIdentifier = "\(DreamPreviewHeaderReusableView.self)"

    private let skView: SKView

    var dream: Dream! {
        didSet {
            guard dream != nil else { return }

            // Update scene to reflect the latest properties.
            skView.allowsTransparency = true
            skView.backgroundColor = .clear

            if let scene = skView.scene as? DreamScene {
                scene.size = frame.size
                scene.dream = dream
            }
            else {
                let scene = DreamScene(dream: dream, size: frame.size)
                skView.presentScene(scene)
            }
        }
    }

    // MARK: Initialization

    override init(frame: CGRect) {
        skView = SKView(frame: CGRect(origin: .zero, size: frame.size))

        super.init(frame: frame)

        addSubview(skView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}
