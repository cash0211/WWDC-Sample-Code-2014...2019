/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperationCondition that composes another OperationCondition.
*/

import Foundation

/**
    A simple condition that causes another condition to not enqueue its dependency.
    This is useful (for example) when you want to verify that you have access to
    the user's location, but you do not want to prompt them for permission if you
    do not already have it.
*/
struct SilentCondition<T: OperationCondition>: OperationCondition {
    let condition: T
    
    static var name: String {
        return "Silent<\(T.name)>"
    }
    
    static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    init(condition: T) {
        self.condition = condition
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        condition.evaluateForOperation(operation, completion: completion)
    }
}
