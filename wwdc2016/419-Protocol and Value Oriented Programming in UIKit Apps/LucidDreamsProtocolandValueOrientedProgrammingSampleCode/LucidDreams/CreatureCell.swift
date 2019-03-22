/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a table view cell used in the `DreamListViewController` to
                display a creature. Note that this cell uses a `DecoratingLayout` to
                layout its content.
*/

import UIKit

/// A table view cell that displays a `Dream.Creature`.
class CreatureCell: UITableViewCell {
    // MARK: Properties

    static let reuseIdentifier = "\(CreatureCell.self)"

    private var content = UILabel()
    private var decoration = UIImageView()

    var creature: Dream.Creature! {
        didSet {
            decoration.image = creature.image
        }
    }

    var title = "" {
        didSet {
            content.text = title
        }
    }

    // MARK: Initialization

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        decoration.contentMode = .scaleAspectFit

        // Add our subviews based on the ordering of the decorating layout's contents.
        let decoratingLayout = DecoratingLayout(content: content, decoration: decoration)
        for view in decoratingLayout.contents {
            contentView.addSubview(view)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        /*
            This is the intersection between the UIKit view code and this sample's
            value based layout system.
        */
        var decoratingLayout = DecoratingLayout(content: content, decoration: decoration)
        decoratingLayout.layout(in: contentView.bounds)
    }
}
