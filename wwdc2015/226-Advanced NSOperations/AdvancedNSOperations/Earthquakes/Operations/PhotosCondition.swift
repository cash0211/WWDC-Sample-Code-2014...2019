/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import Photos

/// A condition for verifying access to the user's Photos library.
struct PhotosCondition: OperationCondition {
    
    static let name = "Photos"
    static let isMutuallyExclusive = false
    
    init() { }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return PhotosPermissionOperation()
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
            case .Authorized:
                completion(.Satisfied)

            default:
                let error = NSError(code: .ConditionFailed, userInfo: [
                    OperationConditionKey: self.dynamicType.name
                ])

                completion(.Failed(error))
        }
    }
}

/**
    A private `Operation` that will request access to the user's Photos, if it
    has not already been granted.
*/
private class PhotosPermissionOperation: Operation {
    override init() {
        super.init()

        addCondition(AlertPresentation())
    }
    
    override func execute() {
        switch PHPhotoLibrary.authorizationStatus() {
            case .NotDetermined:
                dispatch_async(dispatch_get_main_queue()) {
                    PHPhotoLibrary.requestAuthorization { status in
                        self.finish()
                    }
                }
     
            default:
                finish()
        }
    }
    
}

#endif
