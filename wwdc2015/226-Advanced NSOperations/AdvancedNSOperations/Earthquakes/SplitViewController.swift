/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A UISplitViewController subclass that is its own delegate.
*/

import UIKit

class SplitViewController: UISplitViewController {
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        preferredDisplayMode = .allVisible
        
        delegate = self
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        guard let navigation = secondaryViewController as? UINavigationController else { return false }
        guard let detail = navigation.viewControllers.first as? EarthquakeTableViewController else { return false }
        
        return detail.earthquake == nil
    }
}
