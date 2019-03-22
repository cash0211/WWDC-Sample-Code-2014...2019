/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the view controller that's responsible for showing a list of
                dreams. This view controller is the initially displayed view controller
                in the application.
*/

import UIKit

/// Displays a list of `Dream`s and also shows who the user's favorite creature is.
class DreamListViewController: UITableViewController {
    // MARK: Types

    typealias Model = DreamListViewControllerModel

    enum SegueIdentifier: String {
        case showDetail = "showDetail"
        case pickFavoriteCreature = "showFavoriteCreaturePicker"
    }

    enum Section: Int {
        case favoriteCreature = 0
        case dreams = 1

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }

        static let count = 2

        var title: String {
            switch self {
                case .favoriteCreature: return "Favorite Creature"
                case .dreams: return "Dreams"
            }
        }
    }

    // MARK: Properties

    private var state = State.viewing
    private var model = Model.initial

    /// A stored undo manager instance for the `undoManager` property.
    let _undoManager = UndoManager()
    override var undoManager: UndoManager? {
        get { return _undoManager }
    }

    // MARK: Model & State Types

    /**
        This method takes in a closure that can modify the view controller's
        `model` and/or `state` properties. It's important that these two properties
        are changed at the same time because they may both trigger changes to the
        same UI element (e.g. table view updates).
     
        Look at the call sites that use this method to get a better understanding
        of how the model and state properties are changed.

        The crux of this design is that after we mutate the model and state properties
        we perform a diff of the previous values and new values. Based on that diff
        we update our UI with the appropriate changes.

        This is a very nice aspect of this design approach because it centralizes
        our UI update code, preserving "Locality of Reasoning" for our UI (this
        is described in the WWDC session).
    */
    /// it centralizes our UI update code
    func withValues(_ mutations: (inout Model, inout State) -> Void) {
        let oldModel = self.model

        mutations(&self.model, &self.state)

        /*
            The model and state changes can trigger table view updates so we'll
            wrap both calls in a begin/end updates call to the table view.
        */
        tableView.beginUpdates()

        let modelDiff = oldModel.diffed(with: self.model)
        modelDidChange(diff: modelDiff)

        /*
            We don't need to worry about the old state in this example. In your
            app you might need perform different operations based on a combination
            of your old / new state values, so you'd pass the old state as a parameter
            here (similar to the `modelDidChange(...)` approach).
        */
        stateDidChange()

        tableView.endUpdates()
    }

    /// Diffs the model changes and updates the UI based on the new model.
    private func modelDidChange(diff: Model.Diff) {
        // Check to see if we need to update any rows that present a dream.
        if diff.hasAnyDreamChanges {
            switch diff.dreamChange {
                case .inserted?:
                    let indexPath = IndexPath(row: diff.from.dreams.count, section: Section.dreams.rawValue)
                    tableView.insertRows(at: [indexPath], with: .automatic)

                case .removed?:
                    let indexPath = IndexPath(row: diff.from.dreams.count - 1, section: Section.dreams.rawValue)
                    tableView.deleteRows(at: [indexPath], with: .automatic)

                case .updated(let indexes)?:
                    let indexPaths = indexes.map { IndexPath(row: $0, section: Section.dreams.rawValue) }
                    tableView.reloadRows(at: indexPaths, with: .automatic)

                case nil: break
            }
        }

        if diff.favoriteCreatureChanged {
            // Update the favorite creature section header.
            let favoriteCreatureSection = IndexSet(integer: Section.favoriteCreature.rawValue)
            tableView.reloadSections(favoriteCreatureSection, with: .automatic)
        }

        // Need to register any undo changes.
        if diff.hasAnyChanges {
            undoManager?.registerUndo(withTarget: self, handler: { target in
                /*
                    It's important that this `withValues(...)` method is called
                    inside the undo manager rather than setting the model property
                    directly. This is because we want to make sure our UI updates.
                    Note that all we need to do is push the entire old model to
                    the undo stack——a very convenient aspect of this approach.
                */
                target.withValues { model, _ in model = diff.from }
            })
        }
    }

    /// Diffs the state changes and updates the UI based on the new state.
    private func stateDidChange() {
        /*
            We have a bunch of UI components that are dependent on our state. Each
            of them has a local variable that we'll set to a value based on what 
            state we're in. We'll apply those properties to the UI elements at the
            end of this method.
        */
        let editing: Bool
        let rightBarItem: (UIBarButtonSystemItem, enabled: Bool)?

        /*
            A subset of the bar buttons that we can have as a bar button item in
            our app.
        */
        enum LeftBarButton {
            case cancel
            case duplicate
        }
        let leftBarButton: LeftBarButton?

        switch state {
            case .viewing:
                editing = false
                leftBarButton = .duplicate
                rightBarItem = (.action, enabled: true)

            case let .selecting(selectedRows):
                editing = true
                leftBarButton = .cancel
                rightBarItem = (.done, enabled: !selectedRows.isEmpty)

            case let .sharing(dreams):
                editing = false
                leftBarButton = nil
                rightBarItem = (.action, enabled: true)

                if dreams.isEmpty {
                    // No dreams so we don't need to share them.
                    withValues { _, state in state = .viewing }

                    /*
                        Don't perform any UI updates for the current state change
                        since that'll be handled by the `withValues(...)` call
                        above.
                    */
                    return
                } else {
                    share(dreams, completion: {
                        /*
                            Transition to the viewing state after we're completed
                            sharing the dreams.
                        */
                        self.withValues { _, state in state = .viewing }
                    })
                }
            
            case .duplicating:
                editing = false
                leftBarButton = .cancel
                rightBarItem = nil
        }

        // Make sure all the cells have up to date content.
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            if let cell = tableView.cellForRow(at: indexPath) {
                let section = Section(at: indexPath)
                switch section {
                    case .favoriteCreature:
                        if let creatureCell = cell as? CreatureCell {
                            configureCreatureCell(creatureCell, at: indexPath)
                        }

                    case .dreams:
                        if let dreamCell = cell as? DreamCell {
                            configureDreamCell(dreamCell, at: indexPath)
                        }
                }
                
                /*
                    If we came from the `.duplicating` state we need to clear out
                    any cell that was selected.
                */
                if cell.isSelected {
                    if case .selecting = state {
                        // No op.
                    }
                    else {
                        // Clear out the selecting.
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            }
        }
        
        let rightBarButtonItem = rightBarItem.map { barItem, enabled -> UIBarButtonItem in
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: barItem, target: self, action: #selector(DreamListViewController.toggleSelectingRows))

            barButtonItem.isEnabled = enabled

            return barButtonItem
        }
        navigationItem.setRightBarButton(rightBarButtonItem, animated: true)

        let leftBarButtonItem = leftBarButton.map { leftBarButton -> UIBarButtonItem in
            switch leftBarButton {
                case .cancel:
                    return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DreamListViewController.goBackToViewingState))

                case .duplicate:
                    return UIBarButtonItem(title: "Duplicate", style: .plain, target: self, action: #selector(DreamListViewController.startDuplicating))
            }
        }
        navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)

        setEditing(editing, animated: true)
    }

    // MARK: State Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(state.plistRepresentation, forKey: "state")
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if let representation = coder.decodeObject(forKey: "state"),
            var newState = State(plistRepresentation: representation) {
            newState.validateWithModel(model: model)
            withValues { _, state in
                state = newState
            }
        }
    }

    // MARK: View Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // For undo.
        becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // For undo.
        resignFirstResponder()
    }

    // For undo.
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        stateDidChange()

        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.register(CreatureCell.self, forCellReuseIdentifier: CreatureCell.reuseIdentifier)
        tableView.register(DreamCell.self, forCellReuseIdentifier: DreamCell.reuseIdentifier)
    }

    // MARK: UITableViewDelegate & UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
            case .favoriteCreature: return 1
            case .dreams: return model.dreams.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(section).title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(at: indexPath)
        switch section {
            case .favoriteCreature:
                let cell = tableView.dequeueReusableCell(withIdentifier: CreatureCell.reuseIdentifier, for: indexPath) as! CreatureCell
                configureCreatureCell(cell, at: indexPath)
                return cell

            case .dreams:
                let cell = tableView.dequeueReusableCell(withIdentifier: DreamCell.reuseIdentifier, for: indexPath) as! DreamCell
                configureDreamCell(cell, at: indexPath)
                return cell
        }
    }

    func configureCreatureCell(_ cell: CreatureCell, at indexPath: IndexPath) {
        let creature = model.favoriteCreature
        let selectionStyle: UITableViewCellSelectionStyle
        if case .viewing = state {
            selectionStyle = .default
        }
        else {
            selectionStyle = .none
        }

        cell.selectionStyle = selectionStyle
        cell.creature = creature
        cell.title = creature.name
    }

    func configureDreamCell(_ cell: DreamCell, at indexPath: IndexPath) {
        let accessoryType: UITableViewCellAccessoryType
        switch state {
            case .duplicating:
                accessoryType = .none

            case .viewing, .sharing:
                accessoryType = .disclosureIndicator

            case .selecting:
                accessoryType = .none
        }

        cell.accessoryType = accessoryType
        cell.dream = model.dreams[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(at: indexPath)

        switch (section, state) {
            // Only allow changing the favorite creature when in `viewing` mode.
            case (.favoriteCreature, .viewing):
                performSegue(withIdentifier: SegueIdentifier.pickFavoriteCreature.rawValue, sender: nil)

            case (.dreams, _):
                handleDreamTap(at: indexPath)

            default: break
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let section = Section(at: indexPath)
        if case .selecting = state, section == .dreams {
            handleDreamTap(at: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = Section(at: indexPath)

        switch section {
            case .favoriteCreature: return false
            case .dreams: return true
        }
    }

    /// Called when a `Dream` in the list is tapped.
    func handleDreamTap(at indexPath: IndexPath) {
        let row = indexPath.row

        switch state {
            case .sharing: break // no op.

            case .viewing:
                performSegue(withIdentifier: SegueIdentifier.showDetail.rawValue, sender: nil)

            case let .selecting(selectedRows):
                let combinedRows: IndexSet

                if selectedRows.contains(row) {
                    combinedRows = selectedRows.subtracting([row])
                }
                else {
                    combinedRows = selectedRows.union([row])
                }

                withValues { _, state in state = .selecting(selectedRows: combinedRows) }

            case .duplicating:
                withValues { model, _ in
                    var selectedDream = model.dreams[indexPath.row]
                    selectedDream.description += " (copy)"
                    model.append(selectedDream)

                    state = .viewing
                }
        }

    }

    // MARK: Segue Handling

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier.flatMap(SegueIdentifier.init) else { return }

        let selectedDreamIndex = tableView.indexPathForSelectedRow!.row

        switch identifier {
            case .showDetail:
                let detailViewController = segue.destination as! DreamDetailViewController

                let dream = model.dreams[selectedDreamIndex]
                detailViewController.setDream(dream)

                // Register for any changes to the `Dream` while it's being edited.
                detailViewController.dreamDidChange = { [weak self] newDream in
                    guard let strongSelf = self else { return }

                    strongSelf.withValues { model, _ in
                        model[dreamAt: selectedDreamIndex] = newDream
                    }
                }

            case .pickFavoriteCreature:
                let navigationController = segue.destination as! UINavigationController

                let detailViewController = navigationController.viewControllers.first! as! FavoriteCreatureListViewController

                detailViewController.setFavoriteCreature(model.favoriteCreature)

                /*
                    Register for any changes to the favorite creature while its
                    being selected.
                */
                detailViewController.favoriteCreatureDidChange = { [weak self] newFavoriteCreature in
                    guard let strongSelf = self else { return }

                    strongSelf.withValues { model, _ in
                        model.favoriteCreature = newFavoriteCreature
                    }
            }
        }
    }

    @objc func toggleSelectingRows() {
        let newState: State

        switch state {
            case .viewing:
                newState = .selecting(selectedRows: [])

            case let .selecting(selectedRows):
                let selectedDreams = model.dreams[selectedRows]

                newState = .sharing(dreams: selectedDreams)

            case .sharing, .duplicating:
                fatalError("Shouldn't get in this state.")
        }

        withValues { _, state in
            state = newState
        }
    }

    @objc func goBackToViewingState() {
        withValues { _, state in state = .viewing }
    }

    @objc func startDuplicating() {
        withValues { _, state in state = .duplicating }
    }

    /**
        Shares the array of dreams, invoking `completion` when that's complete.
        This disables user interaction until the sharing is complete.
    */
    func share(_ dreams: [Dream], completion: @escaping () -> Void) {
        if presentingViewController == nil {
            view.isUserInteractionEnabled = false

            makeImages(from: dreams, completion: { [weak self] images in
                guard let strongSelf = self else { return }

                strongSelf.view.isUserInteractionEnabled = true

                let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: [])

                activityViewController.completionWithItemsHandler = { _ in
                    completion()
                }

                strongSelf.present(activityViewController, animated: true, completion: nil)
            })
        }
    }
}
