/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Uses retroactive modeling to make `UIView` a `Layout`.
*/

import UIKit

extension UIView: Layout {
    typealias Content = UIView

    func layout(in rect: CGRect) {
        self.frame = rect
    }

    var contents: [Content] {
        return [self]
    }
}
