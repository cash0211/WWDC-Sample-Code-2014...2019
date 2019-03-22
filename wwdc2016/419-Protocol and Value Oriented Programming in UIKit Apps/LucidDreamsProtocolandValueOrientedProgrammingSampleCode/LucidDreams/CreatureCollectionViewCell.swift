/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Provides a simple collection view cell that displays a `Creature`'s
                image. This is used in the `DreamDetailViewController`.
*/

import UIKit

/// A collection view cell that displays a `Dream.Creature`'s image.
class CreatureCollectionViewCell: UICollectionViewCell {
    // MARK: Properties

    static let reuseIdentifier = "\(CreatureCollectionViewCell.self)"

    @IBOutlet var imageView: UIImageView!

    var creature: Dream.Creature! {
        didSet {
            imageView.image = creature?.image
        }
    }

    override var isSelected: Bool {
        set {
            super.isSelected = newValue

            if newValue {
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor.blue.cgColor
            }
            else {
                contentView.layer.borderWidth = 0
                contentView.layer.borderColor = nil
            }
        }

        get { return super.isSelected }
    }
}
