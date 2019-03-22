/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the `FavoriteCreatureListViewController` which displays a list
                of creatures. The user can pick their favorite creature from this
                view controller. This view controller is displayed when the favorite
                creature cell is tapped from the `DreamListViewController`.
*/

import UIKit

/**
    A view controller that displays a list of creatures to select as a user's
    favorite creature.
*/
class FavoriteCreatureListViewController: UITableViewController {
    // MARK: Properties

    var favoriteCreatureDidChange: ((Dream.Creature) -> Void)?

    /*
        We only have one state property for this view controller so we won't create
        a wrapper struct for it.
    */
    private var favoriteCreature: Dream.Creature!

    /**
        Setter accessible to  other view controllers. Only set this before the
        view controller's view has appeared.
    */
    func setFavoriteCreature(_ favoriteCreature: Dream.Creature) {
        self.favoriteCreature = favoriteCreature
    }

    /**
        This method takes in a closure that can modify the view controller's
        `favoriteCreature` property.

        Look at the call sites that use this method to get a better understanding
        of how the model is changed.

        The crux of this design is that after we mutate the favorite creature we
        perform a diff of the previous values and new value. Based on that diff
        we update our UI with the appropriate changes.

        This is a very nice aspect of this design approach because it centralizes
        our UI update code, preserving "Locality of Reasoning" for our UI (this
        is described in the WWDC session).
    */
    func withFavoriteCreature(_ mutateFavoriteCreature: (inout Dream.Creature) -> Void) {
        let old = favoriteCreature

        mutateFavoriteCreature(&favoriteCreature!)

        guard favoriteCreature != old else {
            // If the new and old are the same we just need to deselect the row.
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
            }
            return
        }

        /*
            Perform the diff. Deselect the previously selected cell and select
            the recently tapped one.
        */

        tableView.beginUpdates()
        if let old = old {
            let indexOfPreviousFavoriteCreature = Dream.Creature.all.index(of: old)!
            let indexPathOfPreviousFavoriteCreature = IndexPath(row: indexOfPreviousFavoriteCreature, section: 0)
            tableView.deselectRow(at: indexPathOfPreviousFavoriteCreature, animated: true)
            let previousFavoriteCreatureCell = tableView.cellForRow(at: indexPathOfPreviousFavoriteCreature)
            previousFavoriteCreatureCell?.accessoryType = .none
        }

        let indexOfNewFavoriteCreature = Dream.Creature.all.index(of: favoriteCreature!)!
        let indexPathofNewFavoriteCreature = IndexPath(row: indexOfNewFavoriteCreature, section: 0)
        tableView.deselectRow(at: indexPathofNewFavoriteCreature, animated: true)

        let newFavoriteCreatureCell = tableView.cellForRow(at: indexPathofNewFavoriteCreature)
        newFavoriteCreatureCell?.accessoryType = .checkmark
        
        tableView.endUpdates()
    }

    // MARK: UITableViewDelegate & UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Dream.Creature.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let creature = Dream.Creature.all[indexPath.row]

        if creature == favoriteCreature {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.imageView!.image = creature.image
        cell.textLabel!.text = creature.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        withFavoriteCreature { newFavoriteCreature in
            newFavoriteCreature = Dream.Creature.all[indexPath.row]
        }
    }

    // MARK: IBActions

    @IBAction func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneTapped() {
        favoriteCreatureDidChange?(favoriteCreature)
        dismiss(animated: true, completion: nil)
    }
}
