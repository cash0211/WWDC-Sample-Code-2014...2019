/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to present more information about an earthquake as a modal sheet.
*/

import Foundation
import SafariServices

/// An `Operation` to display an `NSURL` in an app-modal `SFSafariViewController`.
class MoreInformationOperation: Operation {
    // MARK: Properties

    let URL: NSURL
    
    // MARK: Initialization
    
    init(URL: NSURL) {
        self.URL = URL

        super.init()
        
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    // MARK: Overrides
 
    override func execute() {
        dispatch_async(dispatch_get_main_queue()) {
            self.showSafariViewController()
        }
    }
    
    private func showSafariViewController() {
        if let context = UIApplication.sharedApplication().keyWindow?.rootViewController {
            let safari = SFSafariViewController(URL: URL, entersReaderIfAvailable: false)
            safari.delegate = self
            context.presentViewController(safari, animated: true, completion: nil)
        }
        else {
            finish()
        }
    }
}

extension MoreInformationOperation: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true) {
            self.finish()
        }
    }
}
