/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the error codes and convenience functions for interacting with Operation-related errors.
*/

import Foundation

let OperationErrorDomain = "OperationErrors"

enum OperationErrorCode: Int {
    case ConditionFailed = 1
    case ExecutionFailed = 2
}

extension NSError {
    convenience init(code: OperationErrorCode, userInfo: [NSObject: AnyObject]? = nil) {
        self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

// This makes it easy to compare an `NSError.code` to an `OperationErrorCode`.
func ==(lhs: Int, rhs: OperationErrorCode) -> Bool {
    return lhs == rhs.rawValue
}

func ==(lhs: OperationErrorCode, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}
