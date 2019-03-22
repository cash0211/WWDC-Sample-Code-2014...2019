/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `Operation`'s lifecycle.
*/
struct BlockObserver: OperationObserver {
    // MARK: Properties
    
    private let startHandler: (Operation -> Void)?
    private let produceHandler: ((Operation, NSOperation) -> Void)?
    private let finishHandler: ((Operation, [NSError]) -> Void)?
    
    init(startHandler: (Operation -> Void)? = nil, produceHandler: ((Operation, NSOperation) -> Void)? = nil, finishHandler: ((Operation, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(operation: Operation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
