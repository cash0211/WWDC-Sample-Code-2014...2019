/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains an `SKScene` subclass that provides the ability to display 
                a preview for a `Dream`, including effects. Note that the `DreamScene`
                uses a `DreamEffectLayout` to layout its nodes.
*/

import SpriteKit

/**
    Displays a `Dream` inside of a `SKScene`. Performs layout of the scene using
    the `DreamEffectLayout`. This is used in the `DreamPreviewHeaderReusableView`.
*/
class DreamScene: SKScene {
    // MARK: Properties

    var dream: Dream {
        didSet {
            dataDidChange()
        }
    }

    private var decoration: SKSpriteNode?
    private var content: SKLabelNode?
    private var effectNodes: [(Dream.Effect, SKNode)] = []

    // MARK: Initialization

    init(dream: Dream, size: CGSize) {
        self.dream = dream

        super.init(size: size)

        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    // MARK: Scene Callbacks
    
    override func sceneDidLoad() {
        dataDidChange()
    }

    func dataDidChange() {
        // Add all of the nodes to the scene if they haven't been added.
        decoration = decoration ?? {
            let decoration = SKSpriteNode()
            addChild(decoration)
            return decoration
        }()
        decoration!.texture = SKTexture(image: dream.creature.image)

        content = content ?? {
            let content = SKLabelNode()
            content.fontColor = .black
            addChild(content)
            return content
        }()
        content!.text = dream.description

        /*
            Always remove the effect nodes——we'll start from scratch with the new
            effects.
        */
        removeChildren(in: effectNodes.map { $1 })

        effectNodes = dream.effects.map { ($0, $0.makeNode()) }

        // Add all the new effect nodes to the scene.
        for (idx, (_, effectNode)) in effectNodes.enumerated() {
            effectNode.zPosition = CGFloat(idx)

            addChild(effectNode)
        }

        // Now we can layout all the nodes.
        layout()
    }

    override func didMove(to view: SKView) {
        layout()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layout()
    }

    /**
        Lays out all of the nodes in the scene based on the current `Dream`.

        This is the intersection between the SpriteKit node code and this sample's
        value based layout system.
    */
    func layout() {
        guard let decoration = decoration, let content = content else { return }

        /*
            Inset each of the effect nodes an amount that will position the effect
            in the correct place.
        */
        let insettedEffectNodes = effectNodes.map { effect, effectNode in
            return effectNode.withInsets(effect.insetsForDisplaying)
        }
        
        var dreamEffectLayout = DreamEffectLayout(content: content, decoration: decoration, effects: insettedEffectNodes)

        dreamEffectLayout.layout(in: frame)

        /*
            Make the z index for each node in the scene based on the index its in
            the effect layout's contents.
        */
        for (idx, leaf) in dreamEffectLayout.contents.enumerated() {
            leaf.zPosition = CGFloat(idx)
        }
    }
}

extension Dream.Effect {
    fileprivate var insetsForDisplaying: UIEdgeInsets {
        switch self {
            case .fireBreathing:
                return UIEdgeInsets(top: 0, left: 100, bottom: -80, right: 0)

            case .laserFocus:
                return UIEdgeInsets(top: 0, left: 30, bottom: 20, right: 0)

            case .magic, .fireflies, .rain, .snow:
                return .zero
        }
    }
}
