/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the `State` value type for `DreamListViewController`.
*/

import Foundation

extension DreamListViewController {
    /**
        Represents the viewing state of the view controller. Note that because the
        state is an enum, transitions from one state to another are atomic. It
        also means that each of these states are mutually exclusive. Every time
        we need to use our `state` we need to think about which state we really
        care about.
    */
    enum State: Equatable {
        case viewing
        case selecting(selectedRows: IndexSet)
        case duplicating
        case sharing(dreams: [Dream])

        /// Support for archiving and unarchiving state values.
        init?(plistRepresentation: Any) {
            switch plistRepresentation {
                case "viewing" as String:
                    self = .viewing
                    
                case "duplicating" as String:
                    self = .duplicating
                    
                default:
                    if let integers = plistRepresentation as? [Int] {
                        let indexSet = IndexSet(integers)
                        self = .selecting(selectedRows: indexSet)
                    }
                    else {
                        return nil
                    }
            }
        }

        var plistRepresentation: Any {
            switch self {
                case .viewing, .sharing:
                    return "viewing"
                    
                case .selecting(let rows):
                    return rows.map { return $0 }
                
                case .duplicating:
                    return "duplicating"
            }
        }

        /**
            Make sure this `State` is consistent with the given `Model` (for example
            if the `State` and `Model` were loaded independently).
        */
        mutating func validateWithModel(model: Model) {
            if case .selecting(var rows) = self {
                let count = model.dreams.count
                for row in rows {
                    if row >= count {
                        rows.remove(row)
                    }
                }
                self = .selecting(selectedRows: rows)
            }
        }
    }
}

func ==(_ lhs: DreamListViewController.State, _ rhs: DreamListViewController.State) -> Bool {
    switch (lhs, rhs) {
        case (.viewing, .viewing):
            return true
            
        case let (.selecting(leftRows), .selecting(rightRows)):
            return leftRows == rightRows
            
        case (.duplicating, .duplicating):
            return true
            
        case let (.sharing(leftDreams), .sharing(rightDreams)):
            return leftDreams == rightDreams
            
        default:
            return false
    }
}
