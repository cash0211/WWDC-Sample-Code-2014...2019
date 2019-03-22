/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a table view cell used in the `DreamListViewController` to
                display a summary of a dream. Note that this cell uses a `MultiPaneLayout` 
                to layout its content.
*/

import UIKit

/// A table view cell that displays a summary of a `Dream`.
class DreamCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "\(DreamCell.self)"

    var content = UILabel()
    var accessories = [UIImageView]()

    var dream: Dream! {
        didSet {
            // Update the UI when the `dream` changes.
            accessories = (0..<dream.numberOfCreatures).map { _ in
                let imageView = UIImageView(image: dream.creature.image)
                imageView.contentMode = .scaleAspectFit
                return imageView
            }
            content.text = dream.description
            for subview in contentView.subviews {
                subview.removeFromSuperview()
            }
            addSubviews()
            setNeedsLayout()
        }
    }

    // MARK: Initialization

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    // MARK: Layout

    private func addSubviews() {
        let multiPaneLayout = MultiPaneLayout(content: content, accessories: accessories)
        for view in multiPaneLayout.contents {
            contentView.addSubview(view)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        /*
            This is the intersection between the UIKit view code and this sample's
            value based layout system.
        */
        var multiPaneLayout = MultiPaneLayout(content: content, accessories: accessories)
        multiPaneLayout.layout(in: contentView.bounds)
    }
}
