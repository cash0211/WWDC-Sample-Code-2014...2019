/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the `DreamDetailViewController` which displays a `Dream` that
                can be edited. If you tap one of the dreams displayed by the `DreamListViewController`
                you'll be presented this view controller.
*/

import UIKit

/**
    Displays a preview of the user's currently selected dream from the 
    `DreamListViewController`. The `Dream` is editable in this view controller.
    The user can see the preview, all possible creatures, the effects, and more.
*/
class DreamDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: Types

    enum Section: Int {
        case preview
        case description
        case numberOfCreatures
        case creature
        case effect

        static let count = 5

        var numberOfRows: Int {
            switch self {
                case .preview: return 0
                case .description: return 1
                case .numberOfCreatures: return 1
                case .creature: return Dream.Creature.all.count
                case .effect: return Dream.Effect.all.count
            }
        }

        /// A user facing title for the section to be used as a section header.
        var title: String? {
            switch self {
                case .description: return "Description"
                case .numberOfCreatures: return "Number of Creatures"
                case .creature: return "Creatures"
                case .effect: return "Effects"

                default: return nil
            }
        }

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }
    }

    // MARK: Properties

    var dreamDidChange: ((Dream) -> Void)?

    private var dream: Dream!

    /*
        Another view controller can set up this view controller's model by calling
        `setDream(_:)` on it.
    */
    func setDream(_ dream: Dream) {
        self.dream = dream
    }

    /**
        This methiod takes in a closure that can modify the view controller's
        `model` property. 
     
        Look at the call sites that use this method to get a better understanding
        of how the model is changed.

        The crux of this design is that after we mutate the model we perform a diff
        of the previous values and new values. Based on that diff we update our
        UI with the appropriate changes.

        This is a very nice aspect of this design approach because it centralizes
        our UI update code, preserving "Locality of Reasoning" for our UI (this
        is described in the WWDC session).
    */
    private func withDream(_ mutateDream: (inout Dream) -> Void) {
        guard var dream = self.dream else {
            fatalError("A dream should be set by this point.")
        }

        let oldDream = dream

        // Perform the mutations on the dream.
        mutateDream(&dream)

        self.dream = dream

        let diff = oldDream.diffed(with: dream)

        // Update our UI based on the diff of the dreams.
        var indexPathsToDeselect = [IndexPath]()

        if let (fromCreature, _) = diff.creatureChange {
            let indexOfOld = Dream.Creature.all.index(of: fromCreature)!
            let indexPathOfOld = IndexPath(row: indexOfOld, section: Section.creature.rawValue)
            indexPathsToDeselect.append(indexPathOfOld)
        }

        indexPathsToDeselect += diff.removedEffects.map { removedEffect in
            let index = Dream.Effect.all.index(of: removedEffect)!
            return IndexPath(row: index, section: Section.effect.rawValue)
        }

        // Don't need to update collection view if we're already up to date.
        guard diff.hasChanges else { return }

        collectionView?.performBatchUpdates({
            for indexPath in indexPathsToDeselect {
                self.collectionView?.deselectItem(at: indexPath, animated: true)
            }

            self.collectionView?.reloadSections(IndexSet(integer: Section.preview.rawValue))
        }, completion: nil)

    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.allowsMultipleSelection = true

        collectionView?.register(DreamPreviewHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DreamPreviewHeaderReusableView.reuseIdentifier)

        // Set up initially selected cells.
        let selectedCreatureIndex = Dream.Creature.all.index(of: self.dream.creature)!
        let selectedCreatureIndexPath = IndexPath(row: selectedCreatureIndex, section: Section.creature.rawValue)

        let selectedEffectIndexPaths = Dream.Effect.all.enumerated().flatMap { idx, effect -> IndexPath? in
            if dream.effects.contains(effect) {
                return IndexPath(row: idx, section: Section.effect.rawValue)
            }

            return nil
        }

        collectionView?.performBatchUpdates({
            for indexPath in [selectedCreatureIndexPath] + selectedEffectIndexPaths {
                self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dreamDidChange?(dream)
    }

    // MARK: UICollectionViewDelegate & UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Section(section).numberOfRows
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = Section(at: indexPath)

        switch section {
            case .preview: fatalError("No items should be in the preview section.")

            case .description:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextEntryCollectionViewCell.reuseIdentifier, for: indexPath) as! TextEntryCollectionViewCell
                cell.textField.text = dream.description
                cell.textField.keyboardType = .default
                NotificationCenter.default.addObserver(self, selector: #selector(descriptionTextDidChange(_:)), name: .UITextFieldTextDidChange, object: cell.textField)
                return cell

            case .numberOfCreatures:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextEntryCollectionViewCell.reuseIdentifier, for: indexPath) as! TextEntryCollectionViewCell
                cell.textField.text = "\(dream.numberOfCreatures)"
                cell.textField.keyboardType = .numberPad
                NotificationCenter.default.addObserver(self, selector: #selector(numberOfCreaturesTextDidChange(_:)), name: .UITextFieldTextDidChange, object: cell.textField)
                return cell

            case .creature:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreatureCollectionViewCell.reuseIdentifier, for: indexPath) as! CreatureCollectionViewCell

                let creature = Dream.Creature.all[indexPath.row]
                cell.creature = creature

                return cell

            case .effect:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectCollectionViewCell.reuseIdentifier, for: indexPath) as! EffectCollectionViewCell

                let effect = Dream.Effect.all[indexPath.row]
                cell.effect = effect

                return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = Section(at: indexPath)

        withDream { dream in
            switch section {
                case .preview: fatalError("No items should be in the preview section.")

                case .description, .numberOfCreatures:
                    // Selecting the description or numberOfCreatures cell should do nothing to the UI.
                    break

                case .creature:
                    dream.creature = Dream.Creature.all[indexPath.row]

                case .effect:
                    let selectedEffect = Dream.Effect.all[indexPath.row]
                    dream.effects.formSymmetricDifference([selectedEffect])
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let section = Section(at: indexPath)

        switch section {
            case .preview: fatalError("No items should be in the preview section.")

            case .description, .numberOfCreatures:
                // Selecting the `description` or `numberOfCreatures` cell should do nothing to the UI.
                return false

            /* 
                You should never be able deselect a creature. Deselection should
                only be caused by selecting another creature.
            */
            case .creature:
                return false

            // It's always allowed to deselect an effect.
            case .effect:
                return true
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let section = Section(at: indexPath)

        withDream { dream in
            switch section {
                case .preview: fatalError("No items should be in the preview section.")

                case .description, .numberOfCreatures, .creature:
                    break

                case .effect:
                    let effect = Dream.Effect.all[indexPath.row]
                    dream.effects.subtract([effect])
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let section = Section(at: indexPath)

        switch section {
            case .preview, .creature, .effect: return

            case .description, .numberOfCreatures:
                let textEntryCell = cell as! TextEntryCollectionViewCell

                NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: textEntryCell.textField)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("\(type(of: self)) only has a custom section header.")
        }

        let section = Section(at: indexPath)

        switch section {
            case .preview:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DreamPreviewHeaderReusableView.reuseIdentifier, for: indexPath) as! DreamPreviewHeaderReusableView

                headerView.dream = dream

                return headerView

            case .description, .numberOfCreatures, .creature, .effect:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewHeaderReusableView.reuseIdentifier, for: indexPath) as! CollectionViewHeaderReusableView

                headerView.title = section.title!

                return headerView
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch Section(section) {
            case .preview:
                return CGSize(width: collectionView.bounds.width, height: 150)

            default:
                return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = Section(at: indexPath)

        switch section {
            case .preview:
                // There should be no items in the preview section.
                return .zero

            case .description, .numberOfCreatures:
                return CGSize(width: collectionView.bounds.width, height: 45)

            case .creature, .effect:
                return CGSize(width: 90, height: 90)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if Section(section) == .description {
            return .zero
        }

        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    }

    // MARK: UITextFieldTextDidChange Notifications

    @objc func descriptionTextDidChange(_ notification: Notification) {
        let textField = notification.object! as! UITextField

        withDream { $0.description = textField.text ?? "" }
    }

    @objc func numberOfCreaturesTextDidChange(_ notification: Notification) {
        let textField = notification.object! as! UITextField
        if let text = textField.text, let number = Int(text) {
            withDream { $0.numberOfCreatures = number }
        }
    }
}
