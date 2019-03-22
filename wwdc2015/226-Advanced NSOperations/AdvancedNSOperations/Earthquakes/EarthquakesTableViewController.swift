/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The code in this file loads the data store, updates the model, and displays data in the UI.
*/

import UIKit
import CoreData
import CloudKit

class EarthquakesTableViewController: UITableViewController {
    // MARK: Properties

    var fetchedResultsController: NSFetchedResultsController?
    
    let operationQueue = OperationQueue()
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let operation = LoadModelOperation { context in
            // Now that we have a context, build our `FetchedResultsController`.
            DispatchQueue.main.async {
                let request = NSFetchRequest(entityName: Earthquake.entityName)

                request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
                
                request.fetchLimit = 100
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.fetchedResultsController = controller
                
                self.updateUI()
            }
        }

        operationQueue.addOperation(operation)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]

        return section?.numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("earthquakeCell", forIndexPath: indexPath as IndexPath) as! EarthquakeTableViewCell
        
        if let earthquake = fetchedResultsController?.objectAtIndexPath(indexPath) as? Earthquake {
            cell.configure(earthquake)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
            Instead of performing the segue directly, we can wrap it in a `BlockOperation`.
            This allows us to attach conditions to the operation. For example, you
            could make it so that you could only perform the segue if the network
            is reachable and you have access to the user's Photos library.
            
            If you decide to use this pattern in your apps, choose conditions that
            are sensible and do not place onerous requirements on the user.
            
            It's also worth noting that the Observer attached to the `BlockOperation`
            will cause the tableview row to be deselected automatically if the
            `Operation` fails.
            
            You may choose to add your own observer to introspect the errors reported
            as the operation finishes. Doing so would allow you to present a message
            to the user about why you were unable to perform the requested action.
        */
        
        let operation = BlockOperation {
            self.performSegueWithIdentifier("showEarthquake", sender: nil)
        }
        
        operation.addCondition(MutuallyExclusive<UIViewController>())
        
        let blockObserver = BlockObserver { _, errors in
            /*
                If the operation errored (ex: a condition failed) then the segue
                isn't going to happen. We shouldn't leave the row selected.
            */
            if !errors.isEmpty {
                dispatch_async(dispatch_get_main_queue()) {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
        }
        
        operation.addObserver(blockObserver)
        
        operationQueue.addOperation(operation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let navigationVC = segue.destination as? UINavigationController,
            let detailVC = navigationVC.viewControllers.first as? EarthquakeTableViewController else {
            return
        }
        detailVC.queue = operationQueue

        if let indexPath = tableView.indexPathForSelectedRow {
            detailVC.earthquake = fetchedResultsController?.objectAtIndexPath(indexPath) as? Earthquake
        }
    }
    
    @IBAction func startRefreshing(sender: UIRefreshControl) {
        getEarthquakes()
    }
    
    private func getEarthquakes(userInitiated: Bool = true) {
        if let context = fetchedResultsController?.managedObjectContext {
            let getEarthquakesOperation = GetEarthquakesOperation(context: context) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.endRefreshing()
                    self.updateUI()
                }
            }

            getEarthquakesOperation.userInitiated = userInitiated
            operationQueue.addOperation(getEarthquakesOperation)
        }
        else {
            /*
                We don't have a context to operate on, so wait a bit and just make
                the refresh control end.
            */
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }

        tableView.reloadData()
    }

}
