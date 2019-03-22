/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines a simple collection view cell that allows for text entry.
*/

import UIKit

/// A collection view cell that displays a text field.
class TextEntryCollectionViewCell: UICollectionViewCell {
    // MARK: Properties

    static let reuseIdentifier = "\(TextEntryCollectionViewCell.self)"

    @IBOutlet var textField: UITextField!

    // MARK: Life Cycle

    override func awakeFromNib() {
        textField.addTarget(textField, action: #selector(UITextField.resignFirstResponder), for: .editingDidEndOnExit)
    }
}
