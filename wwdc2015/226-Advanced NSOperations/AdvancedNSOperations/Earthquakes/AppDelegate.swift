/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The app delegate. This, by design, has almost no implementation.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties

    var window: UIWindow?
    
    // MARK: UIApplicationDelegate

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        RemoteNotificationCondition.didFailToRegister(error)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        RemoteNotificationCondition.didReceiveNotificationToken(deviceToken)
    }
}
