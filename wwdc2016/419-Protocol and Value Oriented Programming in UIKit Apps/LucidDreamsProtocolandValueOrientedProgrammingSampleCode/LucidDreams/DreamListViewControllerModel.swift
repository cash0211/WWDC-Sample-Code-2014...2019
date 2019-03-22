/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the model for the `DreamListViewController` type. This is in
                a separate file from the `DreamListViewController` class so we can
                test it in isolation without having to import the view controller.
*/

/// Defines the `Model` type for the `DreamListViewController`.
struct DreamListViewControllerModel: Equatable {
    // MARK: Properties

    var favoriteCreature: Dream.Creature

    private var _dreams: [Dream]
    var dreams: [Dream] { return _dreams }

    // MARK: Initialization

    init(favoriteCreature: Dream.Creature, dreams: [Dream]) {
        self.favoriteCreature = favoriteCreature
        _dreams = dreams
    }

    // MARK: Entry Points to Modify / Query Underlying Model

    mutating func append(_ dream: Dream) {
        _dreams.append(dream)
    }

    mutating func removeLast() -> Dream {
        return _dreams.removeLast()
    }

    subscript(dreamAt index: Int) -> Dream {
        get {
            return _dreams[index]
        }
        
        set {
            _dreams[index] = newValue
        }
    }

    /// Set of default data to be used for the model.
    static var initial: DreamListViewControllerModel {
        return DreamListViewControllerModel(favoriteCreature: .unicorn(.pink), dreams: [
            Dream(description: "Dream 1", creature: .unicorn(.pink), effects: [.fireBreathing]),
            Dream(description: "Dream 2", creature: .unicorn(.yellow), effects: [.laserFocus, .magic], numberOfCreatures: 2),
            Dream(description: "Dream 3", creature: .unicorn(.white), effects: [.fireBreathing, .laserFocus], numberOfCreatures: 3)
        ])
    }

    /**
        A type that represents a diff between one `DreamListViewControllerModel`
        and another `DreamListViewControllerModel`.
    */
    struct Diff {
        enum DreamChange: Equatable {
            case inserted(Dream)
            case removed(Dream)
            case updated(at: [Int])
        }

        let dreamChange: DreamChange?
        let from: DreamListViewControllerModel
        let to: DreamListViewControllerModel
        let favoriteCreatureChanged: Bool

        /*
            Private so that the only way to create a diff is using the `diffed(with:)`
            method.
        */
        fileprivate init(dreamChange: DreamChange?, from: DreamListViewControllerModel, to: DreamListViewControllerModel, favoriteCreatureChanged: Bool) {
            self.dreamChange = dreamChange
            self.from = from
            self.to = to
            self.favoriteCreatureChanged = favoriteCreatureChanged
        }

        /**
            Returns `true` if there were any changes to the underlying dreams.
            `false` otherwise.
        */
        var hasAnyDreamChanges: Bool {
            return dreamChange != nil
        }

        /**
            Returns `true` if there were any changes between the `from` and `to`
            models. `false` otherwise.
        */
        var hasAnyChanges: Bool {
            return favoriteCreatureChanged || hasAnyDreamChanges
        }
    }

    /// Returns a diff of `self` and `other`.
    func diffed(with other: DreamListViewControllerModel) -> Diff {
        let dreamChange: Diff.DreamChange?

        /*
            We know that only pushes or pops from the end of the dreams can occur
            so we test that specifically. You might consider writing a more generic
            algorithm that returns inserted, removed, and updated indexes for more
            than just the last item.
        */
        if other.dreams.count - 1 == dreams.count {
            dreamChange = .inserted(other.dreams.last!)
        } else if dreams.count - 1 == other.dreams.count {
            dreamChange = .removed(dreams.last!)
        } else if dreams.count == other.dreams.count {
            let updatedIndexes: [Int] = dreams.enumerated().flatMap { idx, dream in
                if dream != other.dreams[idx] {
                    return idx
                }
                return nil
            }

            if updatedIndexes.isEmpty {
                dreamChange = nil
            } else {
                dreamChange = .updated(at: updatedIndexes)
            }
        } else {
            fatalError("The dreams should never change separate from the statements above.")
        }

        let favoriteCreatureChanged = favoriteCreature != other.favoriteCreature

        return Diff(dreamChange: dreamChange, from: self, to: other, favoriteCreatureChanged: favoriteCreatureChanged)
    }
}

func ==(_ lhs: DreamListViewControllerModel, _ rhs: DreamListViewControllerModel) -> Bool {
    return lhs.favoriteCreature == rhs.favoriteCreature && lhs.dreams == rhs.dreams
}

func ==(_ lhs: DreamListViewControllerModel.Diff.DreamChange, _ rhs: DreamListViewControllerModel.Diff.DreamChange) -> Bool {
    switch (lhs, rhs) {
        case let (.inserted(lhsDream), .inserted(rhsDream)): return lhsDream == rhsDream
        case let (.removed(lhsDream), .removed(rhsDream)): return lhsDream == rhsDream
        case let (.updated(lhsIndexes), .updated(rhsIndexes)): return lhsIndexes == rhsIndexes
        default: return false
    }
}
