//
//  OperationQueue.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation


extension Array where Element: Operation {
    /// Execute block after all operations from the array.
    func onFinish(block: @escaping () -> Void) {
        let doneOperation = BlockOperation(block: block)
        self.forEach { [unowned doneOperation] in doneOperation.addDependency($0) }
        OperationQueue().addOperation(doneOperation)
    }
}
