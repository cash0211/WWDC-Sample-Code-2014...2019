/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Adds functionality to the `Dream` type to be diffed with another
                `Dream`.
*/

extension Dream {
    /// A diff that represents a change from one `Dream` to another `Dream`.
    struct Diff: Equatable {
        // MARK: Properties

        var creatureChange: (from: Creature, to: Creature)?
        var insertedEffects: Set<Effect>
        var removedEffects: Set<Effect>
        var descriptionChange: (from: String, to: String)?

        /*
            Note: this is a private initializer. The canonical way to obtain a diff
            is to call the `diffed(with:)` method.
        */
        fileprivate init(from: Dream, to: Dream) {
            // Creature changes.
            if from.creature != to.creature {
                creatureChange = (from: from.creature, to: to.creature)
            } else {
                creatureChange = nil
            }

            // Effect changes.
            insertedEffects = to.effects.subtracting(from.effects)
            removedEffects = from.effects.subtracting(to.effects)

            // Description changes.
            if from.description != to.description {
                descriptionChange = (from: from.description, to: to.description)
            } else {
                descriptionChange = nil
            }
        }

        var hasChanges: Bool {
            return creatureChange != nil
                || !insertedEffects.isEmpty
                || !removedEffects.isEmpty
                || descriptionChange != nil
        }
    }

    /// Returns the diff between `self` and `other`.
    func diffed(with other: Dream) -> Diff {
        return Diff(from: self, to: other)
    }
}

func ==(_ lhs: Dream.Diff, _ rhs: Dream.Diff) -> Bool {
    switch (lhs.creatureChange, rhs.creatureChange) {
        case let (lhs?, rhs?):
            if lhs.from != rhs.from || lhs.to != rhs.to { return false }
        default: break
    }

    switch (lhs.descriptionChange, rhs.descriptionChange) {
        case let (lhs?, rhs?):
            if lhs.from != rhs.from || lhs.to != rhs.to { return false }
        default: break
    }

    return lhs.insertedEffects == rhs.insertedEffects &&
           lhs.removedEffects == rhs.removedEffects
}
