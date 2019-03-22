/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a simple header view that displays a title.
*/

import UIKit

/// A collection view reusable view that displays a title as a section header.
class CollectionViewHeaderReusableView: UICollectionReusableView {
    // MARK: Properties

    static let reuseIdentifier = "\(CollectionViewHeaderReusableView.self)"

    @IBOutlet var label: UILabel!

    private var _title: String! {
        didSet {
            label.text = _title
        }
    }

    var title: String {
        get { return _title }
        set { _title = newValue }
    }
}
