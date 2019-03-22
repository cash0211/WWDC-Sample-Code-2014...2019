/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Adds functionality to any `RangeReplaceableCollection` that has `Int`
                indices the ability to be subscripted by an `IndexSet`, a Foundation
                type that stores integer indexes.
*/

import Foundation

extension RangeReplaceableCollection where Index == Int {
    /// Returns a collection with elements in `indexes`.
    subscript(indexes: IndexSet) -> Self {
        var new = Self()

        new.reserveCapacity(indexes.count)

        for idx in indexes {
            new.append(self[idx])
        }

        return new
    }
}
