//
//  TextValidationRule.swift
//  MySecret
//
//  Created by Amir lahav on 08/05/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import UIKit

public enum TextValidationRule {
    /// Any input is valid, including an empty string.
    case noRestriction
    /// The input must not be empty.
    case nonEmpty
    /// The enitre input must match a regular expression. A matching substring is not enough.
    case regularExpression(NSRegularExpression)
    /// The input is valid if the predicate function returns `true`.
    case predicate((String) -> Bool)
    
    public func isValid(_ input: String) -> Bool {
        switch self {
        case .noRestriction:
            return true
        case .nonEmpty:
            return !input.isEmpty
        case .regularExpression(let regex):
            let fullNSRange = NSRange(input.startIndex..., in: input)
            return regex.rangeOfFirstMatch(in: input, options: .anchored, range: fullNSRange) == fullNSRange
        case .predicate(let p):
            return p(input)
        }
    }
}
